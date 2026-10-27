#!/usr/bin/env python3
"""Remove Outlast's first-person head bob by stabilising the Hero-Camera track.

How it works
------------
Outlast is a UE3 game whose first-person view is attached to the ``Hero-Camera``
skeleton bone.  The walk/run AnimSequences contain an explicit translation track
for that bone (the only other bone with a translation track is
``Hero-L-UpperArm``).  That track is the head bob: in ``player_walk_forward`` it
oscillates around Z=168.25 cm with an amplitude of ~1.25 cm, plus lateral and
forward sway.  There is no procedural bob in OLHeroCamera, no ``bob`` property
and no AnimTree node that creates it - it is baked into the animations.

This script rewrites the camera keys *in place* (same number of keys, same byte
size) so the camera bone stays still on the axes you choose:

  * translation flatten -> replace every key by the average key (default)
  * rotation flatten    -> replace every key by the average quaternion
  * ``none``            -> leave the track untouched

It never rebuilds the package, so all UE3 offsets stay valid.  The input must be
the *uncompressed* package (``upk/unpacked/OLGame.upk``).  The output keeps the
same package flags (uncompressed, like the provided unpacked file).

Examples
--------
    # Report the bob amplitude of walk/run animations (no write)
    python3 tools/headbob_patch.py --list --mode walk-run

    # Recommended: remove bob while walking/running, translation + rotation
    python3 tools/headbob_patch.py --mode walk-run

    # Remove camera translation in every Hero animation (walk, run, idle,
    # cutscenes...), keep rotation untouched
    python3 tools/headbob_patch.py --mode all --rotation none

    # Custom selection
    python3 tools/headbob_patch.py --match '^player_(walk|run|crouch)'
"""

from __future__ import annotations

import argparse
import json
import math
import os
import re
import shutil
import struct
import sys
from dataclasses import dataclass, field
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from outlast_upk import Export, Package  # noqa: E402

Vec3 = Tuple[float, float, float]
Quat = Tuple[float, float, float, float]


@dataclass
class SeqInfo:
    export: Export
    name: str
    bone_index: int
    translation_count: int
    rotation_count: int
    trans_byte_offset: int
    rot_byte_offset: int
    translation_amplitude: Vec3
    rotation_amplitude_deg: float

    @property
    def max_translation_amplitude(self) -> float:
        return max(self.translation_amplitude)


@dataclass
class PatchReport:
    sequences: List[SeqInfo] = field(default_factory=list)
    modified: int = 0
    translation_keys: int = 0
    rotation_keys: int = 0
    changed_bytes: int = 0


# --------------------------------------------------------------------------- math
def quat_from_xyz(v: Vec3) -> Quat:
    """UE3 ACF_Float96NoW: XYZ stored, W reconstructed as positive."""
    x, y, z = v
    w2 = 1.0 - (x * x + y * y + z * z)
    w = math.sqrt(w2) if w2 > 0.0 else 0.0
    return (x, y, z, w)


def quat_normalize(q: Quat) -> Quat:
    n = math.sqrt(sum(c * c for c in q))
    if n <= 1e-12:
        return (0.0, 0.0, 0.0, 1.0)
    return tuple(c / n for c in q)  # type: ignore[return-value]


def quat_angle_deg(a: Quat, b: Quat) -> float:
    dot = abs(sum(x * y for x, y in zip(a, b)))
    dot = min(1.0, max(-1.0, dot))
    return math.degrees(2.0 * math.acos(dot))


def mean_quaternion(vectors: Sequence[Vec3]) -> Quat:
    """Average a list of (x,y,z) rotation keys with hemisphere alignment."""
    if not vectors:
        return (0.0, 0.0, 0.0, 1.0)
    quats = [quat_from_xyz(v) for v in vectors]
    reference = quats[0]
    acc = [0.0, 0.0, 0.0, 0.0]
    for q in quats:
        if sum(a * b for a, b in zip(q, reference)) < 0.0:
            q = tuple(-c for c in q)  # type: ignore[assignment]
        for i in range(4):
            acc[i] += q[i]
    return quat_normalize(tuple(acc))  # type: ignore[arg-type]


def mean_vector(vectors: Sequence[Vec3]) -> Vec3:
    if not vectors:
        return (0.0, 0.0, 0.0)
    n = float(len(vectors))
    return (
        sum(v[0] for v in vectors) / n,
        sum(v[1] for v in vectors) / n,
        sum(v[2] for v in vectors) / n,
    )


def amplitude(vectors: Sequence[Vec3]) -> Vec3:
    if not vectors:
        return (0.0, 0.0, 0.0)
    return tuple(
        max(v[i] for v in vectors) - min(v[i] for v in vectors) for i in range(3)
    )  # type: ignore[return-value]


# --------------------------------------------------------------------- selection
MODE_PATTERNS = {
    # Cyclic walk/run cycles only.  Special one-shot locomotion such as
    # player_run_door_open_* or player_walk_hurt_* is intentionally excluded:
    # those animations move the camera on purpose and flattening them would
    # freeze the view during the action.
    "walk-run": (
        r"^player_(walk|run)_(forward|backwards?|left|right|strafe_left|strafe_right)"
        r"(_water)?$"
    ),
    # Every player_walk_* / player_run_* sequence, including hurt/hobble/door.
    "walk-run-all": r"^player_(walk|run)",
    "walk": r"^player_walk",
    "run": r"^player_run",
    "all": None,
}

DEFAULT_ANIMSETS = ("Hero-01_AS", "Hero_SE")


def collect(
    pkg: Package,
    *,
    animsets: Sequence[str],
    bone: str,
    pattern: Optional[str],
) -> List[Tuple[SeqInfo, List[Vec3], List[Vec3], Dict[str, object]]]:
    wanted = set(animsets)
    regex = re.compile(pattern) if pattern else None
    seen = set()
    out: List[Tuple[SeqInfo, List[Vec3], List[Vec3], Dict[str, object]]] = []
    for animset in pkg.iter_anim_sets():
        if animset.name not in wanted:
            continue
        bones = pkg.animset_track_bones(animset)
        if bone not in bones:
            continue
        bone_index = bones.index(bone)
        for sequence in pkg.animset_sequences(animset):
            if sequence.index in seen:
                continue
            name = pkg.anim_sequence_name(sequence)
            if regex is not None and not regex.search(name):
                continue
            try:
                translations, rotations, info = pkg.anim_camera_track(
                    sequence, bone_index
                )
            except ValueError as exc:
                print(f"  ! skipping {name}: {exc}", file=sys.stderr)
                continue
            if not translations or not rotations:
                continue
            seen.add(sequence.index)
            trans_amp = amplitude(translations)
            quats = [quat_from_xyz(v) for v in rotations]
            rot_amp = max(quat_angle_deg(q, quats[0]) for q in quats)
            info_row = SeqInfo(
                export=sequence,
                name=name,
                bone_index=bone_index,
                translation_count=len(translations),
                rotation_count=len(rotations),
                trans_byte_offset=int(info["translation_byte_offset"]),
                rot_byte_offset=int(info["rotation_byte_offset"]),
                translation_amplitude=trans_amp,
                rotation_amplitude_deg=rot_amp,
            )
            out.append((info_row, translations, rotations, info))
    return out


# ----------------------------------------------------------------------- patching
def write_vec3(data: bytearray, offset: int, value: Vec3) -> None:
    struct.pack_into("<3f", data, offset, *value)


def patch(
    pkg: Package,
    rows: Sequence[Tuple[SeqInfo, List[Vec3], List[Vec3], Dict[str, object]]],
    *,
    translation: str,
    rotation: str,
    translation_anchor: str = "mean",
    dry_run: bool = False,
) -> PatchReport:
    report = PatchReport(sequences=[row[0] for row in rows])
    before = bytes(pkg.data)
    data = bytearray(pkg.data)
    for row, translations, rotations, _info in rows:
        changed = False
        if translation != "none" and len(translations) > 1:
            if translation_anchor == "first":
                target = translations[0]
            else:
                target = mean_vector(translations)
            for i in range(len(translations)):
                write_vec3(data, row.trans_byte_offset + i * 12, target)
            report.translation_keys += len(translations)
            changed = True
        if rotation != "none" and len(rotations) > 1:
            q = mean_quaternion(rotations)
            target = (q[0], q[1], q[2])
            for i in range(len(rotations)):
                write_vec3(data, row.rot_byte_offset + i * 12, target)
            report.rotation_keys += len(rotations)
            changed = True
        if changed:
            report.modified += 1
    # Count changed bytes (in-place, so the size must be identical).
    if len(data) != len(before):
        raise RuntimeError("internal error: patch changed the package size")
    report.changed_bytes = sum(1 for a, b in zip(before, data) if a != b)
    if not dry_run:
        pkg.data = data
    return report



# --------------------------------------------------------------------- validation
def validate(
    path: str,
    rows: Sequence[Tuple[SeqInfo, List[Vec3], List[Vec3], Dict[str, object]]],
    *,
    bone: str,
    translation: str,
    rotation: str,
) -> List[str]:
    """Re-open the written package and verify the patched tracks are stable."""
    errors: List[str] = []
    out = Package(path)
    for row, _t, _r, _info in rows:
        sequence = out.exports[row.export.index]
        translations, rotations, _ = out.anim_camera_track(sequence, row.bone_index)
        if translation != "none" and len(translations) > 1:
            amp = max(amplitude(translations))
            if amp > 1e-5:
                errors.append(f"{row.name}: translation still varies by {amp:.6f}")
        if rotation != "none" and len(rotations) > 1:
            quats = [quat_from_xyz(v) for v in rotations]
            deg = max(quat_angle_deg(q, quats[0]) for q in quats)
            if deg > 1e-4:
                errors.append(f"{row.name}: rotation still varies by {deg:.6f} deg")
    return errors



# --------------------------------------------------------------------------- CLI
def print_table(rows: Sequence[Tuple[SeqInfo, List[Vec3], List[Vec3], Dict[str, object]]]) -> None:
    print(f"{'AnimSequence':34s} {'pos keys':>8s} {'rot keys':>8s} "
          f"{'dX':>7s} {'dY':>7s} {'dZ':>7s} {'rot deg':>8s}")
    print("-" * 90)
    for row, _t, _r, _info in sorted(rows, key=lambda r: r[0].name):
        dx, dy, dz = row.translation_amplitude
        print(f"{row.name:34s} {row.translation_count:8d} {row.rotation_count:8d} "
              f"{dx:7.2f} {dy:7.2f} {dz:7.2f} {row.rotation_amplitude_deg:8.2f}")


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = argparse.ArgumentParser(
        description="Remove Outlast head bob by stabilising the Hero-Camera animation track."
    )
    parser.add_argument(
        "--in", dest="input", default="upk/unpacked/OLGame.upk",
        help="uncompressed OLGame.upk (default: upk/unpacked/OLGame.upk)",
    )
    parser.add_argument(
        "--out", dest="output", default="build/OLGame_headbob_fixed.upk",
        help="output package (default: build/OLGame_headbob_fixed.upk)",
    )
    parser.add_argument(
        "--mode", choices=sorted(MODE_PATTERNS), default="walk-run",
        help="animation selection preset (default: walk-run)",
    )
    parser.add_argument(
        "--match", default=None,
        help="custom regex on the AnimSequence name (overrides --mode)",
    )
    parser.add_argument(
        "--animset", default=",".join(DEFAULT_ANIMSETS),
        help="comma separated AnimSet names (default: Hero-01_AS,Hero_SE)",
    )
    parser.add_argument("--bone", default="Hero-Camera", help="camera bone name")
    parser.add_argument(
        "--translation", choices=("flatten", "none"), default="flatten",
        help="translation stabilisation (default: flatten to mean)",
    )
    parser.add_argument(
        "--translation-anchor", choices=("mean", "first"), default="mean",
        help="constant used when flattening translation (default: mean)",
    )
    parser.add_argument(
        "--rotation", choices=("flatten", "none"), default=None,
        help="rotation stabilisation (default: flatten for walk-run, none for all)",
    )
    parser.add_argument("--list", action="store_true", help="only list matching animations")
    parser.add_argument("--dry-run", action="store_true", help="do not write the package")
    parser.add_argument("--json", default="build/headbob_report.json",
                        help="report path (default: build/headbob_report.json)")
    args = parser.parse_args(argv)

    if args.rotation is None:
        args.rotation = "flatten" if args.mode != "all" else "none"

    pkg = Package(args.input)
    if pkg.is_compressed_package():
        print(
            "ERROR: this package is compressed. Use the decompressed file, e.g. "
            "upk/unpacked/OLGame.upk.",
            file=sys.stderr,
        )

    pattern = args.match if args.match is not None else MODE_PATTERNS[args.mode]
    animsets = [x.strip() for x in args.animset.split(",") if x.strip()]
    rows = collect(pkg, animsets=animsets, bone=args.bone, pattern=pattern)
    if not rows:
        print("No matching AnimSequences with a camera track were found.", file=sys.stderr)
        return 1

    print(f"Package : {args.input}")
    print(f"AnimSets: {', '.join(animsets)}")
    print(f"Selection: {pattern or 'all sequences'}")
    print(f"Camera bone: {args.bone}")
    print(f"Matched : {len(rows)} animation sequences\n")
    print_table(rows)

    if args.list:
        return 0

    report = patch(
        pkg,
        rows,
        translation=args.translation,
        rotation=args.rotation,
        translation_anchor=args.translation_anchor,
        dry_run=args.dry_run,
    )
    print(
        f"\nPatched {report.modified} sequences: "
        f"{report.translation_keys} translation keys, "
        f"{report.rotation_keys} rotation keys, "
        f"{report.changed_bytes} bytes changed."
    )

    if args.dry_run:
        print("Dry run: no file written.")
        return 0

    os.makedirs(os.path.dirname(args.output) or ".", exist_ok=True)
    with open(args.output, "wb") as fh:
        fh.write(pkg.data)
    print(f"Written : {args.output} ({len(pkg.data):,} bytes)")

    errors = validate(
        args.output, rows, bone=args.bone,
        translation=args.translation, rotation=args.rotation,
    )
    if errors:
        print("\nVALIDATION FAILED:", file=sys.stderr)
        for error in errors[:20]:
            print("  -", error, file=sys.stderr)
        return 3
    print("Validation: OK (camera tracks are stable; package size unchanged)")

    os.makedirs(os.path.dirname(args.json) or ".", exist_ok=True)
    with open(args.json, "w", encoding="utf-8") as fh:
        json.dump(
            {
                "input": args.input,
                "output": args.output,
                "bone": args.bone,
                "mode": args.mode,
                "match": pattern,
                "translation": args.translation,
                "rotation": args.rotation,
                "modified_sequences": report.modified,
                "translation_keys": report.translation_keys,
                "rotation_keys": report.rotation_keys,
                "changed_bytes": report.changed_bytes,
                "sequences": [
                    {
                        "index": row.export.index,
                        "name": row.name,
                        "translation_amplitude": row.translation_amplitude,
                        "rotation_amplitude_deg": row.rotation_amplitude_deg,
                    }
                    for row in report.sequences
                ],
            },
            fh,
            indent=2,
        )
    print(f"Report  : {args.json}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
