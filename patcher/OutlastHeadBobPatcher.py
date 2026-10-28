#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Outlast - Head Bob Patcher
==========================

Removes head bob from Outlast by editing the keyframes of the "Hero-Camera" bone
inside OLGame.upk (seekfree package containing Miles's animations).

How the game works (summary):
  * OLPlayerController.GetPlayerViewPoint() calls OLHero.GetCamera() (native).
  * OLHeroCamera.Update() reads the "Hero-Camera" bone location/rotation directly
    from the animation (Mesh.GetBoneLocation/GetBoneQuaternion) and applies
    shakes/neck offset.
  * Therefore, the walk/run/breathing bob is stored in the keyframes of this
    bone in the AnimSequence of the AnimSet "03_Hero.Hero-01_AS", inside OLGame.upk.

The patcher flattens (sets constant) these keyframes only for the chosen
animations, without changing sizes, offsets, or any other package data.

Usage:
  GUI:  python OutlastHeadBobPatcher.py
  CLI:  python OutlastHeadBobPatcher.py --cli --package OLGame.upk --mode default --breathing

Requirements:
  * Python 3.8+ (tkinter for GUI).
  * If OLGame.upk is compressed, "decompress.exe" (Gildor's PackageUnpack,
    included in this folder) must be next to this script.

The original OLGame.upk is saved as "OLGame.upk.backup" on first
application. "Restore original file" renames the backup back.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
import queue
import shutil
import struct
import subprocess
import sys
import tempfile
import threading
import time
import traceback

APP_TITLE = "Outlast - Head Bob Patcher"
APP_VERSION = "1.0"

PACKAGE_NAME = "OLGame.upk"
BACKUP_NAME = "OLGame.upk.backup"
STATE_NAME = "OLGame.headbob.json"
DECOMPRESS_NAME = "decompress.exe"

ANIMSET_NAME = "Hero-01_AS"
ANIMSET_PACKAGE = "03_Hero"
CAMERA_BONE = "Hero-Camera"

PKG_COMPRESSED = 0x02000000

# Animacoes normais de caminhada/corrida usadas no modo "padrao".
WALK_RUN_DEFAULT = {
    "player_walk_forward",
    "player_walk_backward",
    "player_walk_strafe_left",
    "player_walk_strafe_right",
    "player_walk_forward_water",
    "player_walk_backward_water",
    "player_walk_strafe_left_water",
    "player_walk_strafe_right_water",
    "player_run_forward",
    "player_run_backwards",
    "player_run_left",
    "player_run_right",
}

MODE_ORDER = ["default", "walk_run_all", "walk", "run", "all"]

MODE_LABELS = {
    "default": "Walk + Run (default)",
    "walk_run_all": "Walk + Run (all)",
    "walk": "Walk only",
    "run": "Run only",
    "all": "All animations",
}

MODE_DESCRIPTIONS = {
    "default": (
        "Removes bob only from normal walk and run cycles "
        "(forward, backward, strafes, and water variants). Recommended for playing "
        "without motion sickness, without touching jumps, falls, or interactions."
    ),
    "walk_run_all": (
        "Removes bob from ALL animations that have 'walk' or 'run' in the name, "
        "including crouching, limping, injured, stairs, jumps, and "
        "transitions (any animation with walk/run)."
    ),
    "walk": (
        "All walk animations ('walk'), including variants "
        "(water, limping, injured) and transitions."
    ),
    "run": (
        "All run animations ('run'), including variants "
        "(limping) and transitions."
    ),
    "all": (
        "Removes bob from ALL Miles animations (idle, walk, run, "
        "crouch, jumps, falls, interactions, fatalities). Maximum removal; may "
        "alter scripted gameplay animations."
    ),
}

BREATHING_DESCRIPTION = (
    "Eliminates breathing camera shake when Miles is idle (standing still), "
    "including crouched, leaning, in bed, inside a locker, or holding the "
    "camera. Recommended."
)

# ---------------------------------------------------------------------------
# Leitor de pacotes UE3 (Outlast: versao 868, licensee 3)
# ---------------------------------------------------------------------------


class PatchError(Exception):
    """Expected error, shown to user without traceback."""


def _align4(n: int) -> int:
    return (n + 3) & ~3


class Export:
    __slots__ = (
        "index", "class_index", "super_index", "outer_index", "name",
        "archetype_index", "object_flags", "serial_size", "serial_offset",
        "export_flags", "generations", "package_guid", "package_flags",
    )

    def __init__(self, **kwargs):
        for key, value in kwargs.items():
            setattr(self, key, value)

    def __repr__(self):
        return "<Export %d %r>" % (self.index, self.name)


class Import:
    __slots__ = ("index", "class_package", "class_name", "outer_index", "name")

    def __init__(self, **kwargs):
        for key, value in kwargs.items():
            setattr(self, key, value)

    def __repr__(self):
        return "<Import %d %r>" % (self.index, self.name)


def read_package_header(data: bytes) -> dict:
    """Reads only the header (also works in compressed packages)."""
    if len(data) < 64:
        raise PatchError("File too small to be an Outlast .upk.")
    tag = struct.unpack_from("<I", data, 0)[0]
    if tag != 0x9E2A83C1:
        raise PatchError("Invalid package tag (does not look like a UE3 .upk).")

    version, licensee = struct.unpack_from("<HH", data, 4)
    header_size = struct.unpack_from("<i", data, 8)[0]

    folder_len = struct.unpack_from("<i", data, 12)[0]
    if folder_len >= 0:
        folder_raw = data[16:16 + folder_len]
        folder = folder_raw.rstrip(b"\x00").decode("latin-1")
        off = 16 + folder_len
    else:
        folder_len = -folder_len
        folder_raw = data[16:16 + folder_len * 2]
        folder = folder_raw.decode("utf-16-le").rstrip("\x00")
        off = 16 + folder_len * 2

    package_flags = struct.unpack_from("<I", data, off)[0]
    off += 4
    (name_count, name_offset,
     export_count, export_offset,
     import_count, import_offset,
     depends_offset) = struct.unpack_from("<7i", data, off)

    return {
        "version": version,
        "licensee": licensee,
        "header_size": header_size,
        "folder": folder,
        "package_flags": package_flags,
        "name_count": name_count,
        "name_offset": name_offset,
        "export_count": export_count,
        "export_offset": export_offset,
        "import_count": import_count,
        "import_offset": import_offset,
        "depends_offset": depends_offset,
        "compressed": bool(package_flags & PKG_COMPRESSED),
    }

class UpkPackage:
    """Leitor minimo de pacotes UE3 cookados do Outlast."""

    KNOWN_TYPES = {
        "StructProperty", "BoolProperty", "ByteProperty", "IntProperty",
        "FloatProperty", "ObjectProperty", "NameProperty", "ArrayProperty",
        "StrProperty", "ComponentProperty", "DelegateProperty",
        "InterfaceProperty", "MapProperty", "FixedArrayProperty",
    }

    def __init__(self, data: bytes, path: str = ""):
        self.data = data
        self.path = path
        self.header = read_package_header(data)
        self.version = self.header["version"]
        self.licensee = self.header["licensee"]
        self.package_flags = self.header["package_flags"]
        if self.header["compressed"]:
            raise PatchError(
                "The package is compressed; it must be decompressed before "
                "de ser lido/editado."
            )
        self.names = []
        self.imports = []
        self.exports = []
        self._parse_names()
        self._parse_imports()
        self._parse_exports()

    # -- helpers ---------------------------------------------------------
    def _u32(self, off: int) -> int:
        return struct.unpack_from("<I", self.data, off)[0]

    def _i32(self, off: int) -> int:
        return struct.unpack_from("<i", self.data, off)[0]

    def _fname(self, off: int):
        return (self._i32(off), self._i32(off + 4))

    # -- tabelas ---------------------------------------------------------
    def _parse_names(self):
        off = self.header["name_offset"]
        names = []
        for _ in range(self.header["name_count"]):
            n = self._i32(off)
            if n < 0:
                n = -n
                raw = self.data[off + 4:off + 4 + n * 2]
                names.append(raw.decode("utf-16-le").rstrip("\x00"))
                off += 4 + n * 2
            elif n > 0:
                raw = self.data[off + 4:off + 4 + n]
                names.append(raw[:-1].decode("latin-1"))
                off += 4 + n
            else:
                raise PatchError("Invalid name table in .upk.")
            off += 8  # flags do nome (uint64)
        self.names = names

    def _parse_imports(self):
        off = self.header["import_offset"]
        imports = []
        for index in range(self.header["import_count"]):
            class_package = self._fname(off)
            class_name = self._fname(off + 8)
            outer_index = self._i32(off + 16)
            name = self._fname(off + 20)
            imports.append(Import(
                index=index, class_package=class_package,
                class_name=class_name, outer_index=outer_index, name=name,
            ))
            off += 28
        self.imports = imports

    def _parse_exports(self):
        off = self.header["export_offset"]
        exports = []
        for index in range(self.header["export_count"]):
            class_index = self._i32(off)
            super_index = self._i32(off + 4)
            outer_index = self._i32(off + 8)
            name = self._fname(off + 12)
            archetype_index = self._i32(off + 20)
            object_flags = struct.unpack_from("<Q", self.data, off + 24)[0]
            serial_size = self._i32(off + 32)
            serial_offset = self._i32(off + 36)
            export_flags = self._i32(off + 40)
            generation_count = self._i32(off + 44)
            pos = off + 48
            generations = [self._i32(pos + 4 * j) for j in range(generation_count)]
            pos += 4 * generation_count
            package_guid = self.data[pos:pos + 16]
            pos += 16
            package_flags = self._u32(pos)
            pos += 4
            exports.append(Export(
                index=index, class_index=class_index, super_index=super_index,
                outer_index=outer_index, name=name,
                archetype_index=archetype_index, object_flags=object_flags,
                serial_size=serial_size, serial_offset=serial_offset,
                export_flags=export_flags, generations=generations,
                package_guid=package_guid, package_flags=package_flags,
            ))
            off = pos
        self.exports = exports

    # -- resolucao -------------------------------------------------------
    def name(self, fname) -> str:
        return self.names[fname[0]]

    def object_at(self, index):
        if index < 0:
            pos = -index - 1
            return self.imports[pos] if pos < len(self.imports) else None
        if index > 0:
            pos = index - 1
            return self.exports[pos] if pos < len(self.exports) else None
        return None

    def object_name(self, index):
        obj = self.object_at(index)
        return None if obj is None else self.name(obj.name)

    def class_name_of(self, export):
        cls = self.object_at(export.class_index)
        return None if cls is None else self.name(cls.name)

    def outer_path(self, export) -> str:
        parts = []
        obj = export
        seen = 0
        while obj is not None and seen < 16:
            parts.append(self.name(obj.name))
            if obj.outer_index == 0:
                break
            obj = self.object_at(obj.outer_index)
            seen += 1
        return ".".join(reversed(parts))

    # -- propriedades (tagged properties) --------------------------------
    def _try_props(self, off: int, end: int, prefix: int):
        p = off + prefix
        props = []
        ended = False
        while p + 8 <= end:
            name_index = self._i32(p)
            if name_index < 0 or name_index >= len(self.names):
                return props, p, False
            prop_name = self.names[name_index]
            if prop_name == "None":
                ended = True
                break
            if p + 24 > end:
                break
            type_index = self._i32(p + 8)
            if type_index < 0 or type_index >= len(self.names):
                return props, p, False
            prop_type = self.names[type_index]
            if prop_type not in self.KNOWN_TYPES:
                return props, p, False
            size = self._i32(p + 16)
            array_index = self._i32(p + 20)
            value_off = p + 24
            if prop_type == "StructProperty":
                value_off += 8
            elif prop_type == "BoolProperty":
                value_off += 1
            elif prop_type == "ByteProperty":
                value_off += 8
            if size < 0 or value_off + size > end:
                return props, p, False
            props.append({
                "name": prop_name, "type": prop_type, "size": size,
                "array": array_index, "tag": p, "value": value_off,
                "end": value_off + size,
            })
            p = value_off + size
        return props, p, ended

    def parse_properties(self, export):
        """Retorna (props_dict, posicao_do_tag_None)."""
        start = export.serial_offset
        end = start + export.serial_size
        best = None
        for prefix in (4, 0, 8, 12, 2, 6, 10):
            props, stop, ended = self._try_props(start, end, prefix)
            if not props:
                continue
            score = len(props) + (1000 if ended else 0)
            if best is None or score > best[0]:
                best = (score, props, stop, ended, prefix)
        if best is None:
            raise PatchError("Could not read object properties.")
        _, props, stop, ended, prefix = best
        by_name = {}
        for prop in props:
            by_name.setdefault(prop["name"], []).append(prop)
        return by_name, stop

# ---------------------------------------------------------------------------
# Animacoes do heroi
# ---------------------------------------------------------------------------


def _read_name_array(pkg: UpkPackage, prop) -> list:
    data = pkg.data
    count = struct.unpack_from("<i", data, prop["value"])[0]
    if count < 0 or count > 4096:
        raise PatchError("Invalid name array.")
    out = []
    off = prop["value"] + 4
    for _ in range(count):
        index = struct.unpack_from("<i", data, off)[0]
        if index < 0 or index >= len(pkg.names):
            raise PatchError("Invalid name index.")
        out.append(pkg.names[index])
        off += 8
    return out


def _read_int_array(pkg: UpkPackage, prop) -> list:
    data = pkg.data
    count = struct.unpack_from("<i", data, prop["value"])[0]
    if count < 0 or count > 65536:
        raise PatchError("Invalid integer array.")
    start = prop["value"] + 4
    return [struct.unpack_from("<i", data, start + 4 * i)[0] for i in range(count)]


def _read_object_array(pkg: UpkPackage, prop) -> list:
    return _read_int_array(pkg, prop)


class CameraTrack:
    """Keyframes da bone Hero-Camera em um AnimSequence."""

    __slots__ = (
        "export", "sequence_name", "trans_off", "trans_keys",
        "rot_off", "rot_keys", "stream_start", "stream_count",
        "layout_ok", "layout_error",
    )

    def __init__(self, **kwargs):
        for key, value in kwargs.items():
            setattr(self, key, value)

    def __repr__(self):
        return "<CameraTrack %s trans=%d rot=%d>" % (
            self.sequence_name, self.trans_keys, self.rot_keys)


def find_hero_animset(pkg: UpkPackage):
    candidates = [
        e for e in pkg.exports
        if pkg.class_name_of(e) == "AnimSet" and pkg.name(e.name) == ANIMSET_NAME
    ]
    if not candidates:
        return None
    for export in candidates:
        if ANIMSET_PACKAGE in pkg.outer_path(export):
            return export
    return candidates[0]


def _validate_layout(offsets: list, stream_count: int) -> tuple:
    """Confere se os offsets batem com o layout per-track (12 bytes/key)."""
    pos = 0
    bones = len(offsets) // 4
    for bone in range(bones):
        trans_off, trans_n, rot_off, rot_n = offsets[4 * bone:4 * bone + 4]
        if trans_off != pos:
            return False, "bone %d: trans %d != %d" % (bone, trans_off, pos)
        if trans_n < 0 or trans_n > 4096:
            return False, "bone %d: trans keys invalidas" % bone
        pos = trans_off + trans_n * 12 + (_align4(trans_n) if trans_n > 1 else 0)
        if rot_off != pos:
            return False, "bone %d: rot %d != %d" % (bone, rot_off, pos)
        if rot_n < 0 or rot_n > 4096:
            return False, "bone %d: rot keys invalidas" % bone
        pos = rot_off + rot_n * 12 + (_align4(rot_n) if rot_n > 1 else 0)
    if pos != stream_count:
        return False, "fim %d != %d" % (pos, stream_count)
    return True, ""


def list_camera_tracks(pkg: UpkPackage, animset_export=None) -> list:
    """Retorna todos os CameraTrack do AnimSet Hero-01_AS."""
    if animset_export is None:
        animset_export = find_hero_animset(pkg)
    if animset_export is None:
        raise PatchError(
            "AnimSet '%s' not found in OLGame.upk. "
            "The file may be from another game version." % ANIMSET_NAME
        )

    data = pkg.data
    props, stop = pkg.parse_properties(animset_export)
    if "TrackBoneNames" not in props:
        raise PatchError("AnimSet without bone list (TrackBoneNames).")
    bone_names = _read_name_array(pkg, props["TrackBoneNames"][0])
    try:
        camera_index = [n.lower() for n in bone_names].index(CAMERA_BONE.lower())
    except ValueError:
        raise PatchError(
            "Bone '%s' does not exist in AnimSet. Unexpected animation format."
            % CAMERA_BONE
        )

    if "Sequences" not in props:
        raise PatchError("AnimSet without sequence list.")
    sequence_refs = _read_object_array(pkg, props["Sequences"][0])

    tracks = []
    for ref in sequence_refs:
        if ref <= 0:
            continue
        export = pkg.object_at(ref)
        if export is None or pkg.class_name_of(export) != "AnimSequence":
            continue
        try:
            seq_props, seq_stop = pkg.parse_properties(export)
        except PatchError:
            continue
        if "CompressedTrackOffsets" not in seq_props:
            continue

        sequence_name = ""
        if "SequenceName" in seq_props:
            name_off = seq_props["SequenceName"][0]["value"]
            name_index = struct.unpack_from("<i", data, name_off)[0]
            if 0 <= name_index < len(pkg.names):
                sequence_name = pkg.names[name_index]
        if not sequence_name:
            sequence_name = "export_%d" % export.index

        offsets = _read_int_array(pkg, seq_props["CompressedTrackOffsets"][0])
        if len(offsets) < 4 * (camera_index + 1):
            continue

        trans_off, trans_keys, rot_off, rot_keys = offsets[
            4 * camera_index:4 * camera_index + 4
        ]

        stream_start = seq_stop + 16
        stream_count = struct.unpack_from("<i", data, seq_stop + 12)[0]
        export_end = export.serial_offset + export.serial_size
        layout_ok = True
        layout_error = ""
        if stream_count < 0 or stream_start + stream_count != export_end:
            layout_ok = False
            layout_error = "stream size does not match"
        else:
            layout_ok, layout_error = _validate_layout(offsets, stream_count)

        tracks.append(CameraTrack(
            export=export, sequence_name=sequence_name,
            trans_off=trans_off, trans_keys=trans_keys,
            rot_off=rot_off, rot_keys=rot_keys,
            stream_start=stream_start, stream_count=stream_count,
            layout_ok=layout_ok, layout_error=layout_error,
        ))
    return tracks


def is_idle(name: str) -> bool:
    return "idle" in name.lower()


def track_matches(name: str, mode: str, breathing: bool) -> bool:
    if breathing and is_idle(name):
        return True
    if mode == "default":
        return name in WALK_RUN_DEFAULT
    if mode == "walk_run_all":
        return "_walk_" in name or "_run_" in name
    if mode == "walk":
        return "_walk_" in name
    if mode == "run":
        return "_run_" in name
    if mode == "all":
        return True
    raise PatchError("Unknown removal mode: %s" % mode)


def count_tracks_for_mode(tracks: list, mode: str, breathing: bool) -> int:
    return sum(1 for t in tracks if track_matches(t.sequence_name, mode, breathing))

# ---------------------------------------------------------------------------
# Patch dos keyframes
# ---------------------------------------------------------------------------


def _translation_keys(buf, track) -> list:
    base = track.stream_start + track.trans_off
    return [struct.unpack_from("<3f", buf, base + 12 * i)
            for i in range(track.trans_keys)]


def _rotation_keys(buf, track) -> list:
    base = track.stream_start + track.rot_off
    out = []
    for i in range(track.rot_keys):
        x, y, z = struct.unpack_from("<3f", buf, base + 12 * i)
        w2 = 1.0 - x * x - y * y - z * z
        out.append((x, y, z, math.sqrt(w2) if w2 > 0.0 else 0.0))
    return out


def _max_translation_deviation(keys) -> float:
    if not keys:
        return 0.0
    cx = sum(k[0] for k in keys) / len(keys)
    cy = sum(k[1] for k in keys) / len(keys)
    cz = sum(k[2] for k in keys) / len(keys)
    return max(max(abs(k[0] - cx), abs(k[1] - cy), abs(k[2] - cz)) for k in keys)


def _max_rotation_deviation(keys) -> float:
    if len(keys) < 2:
        return 0.0
    ref = keys[0]
    worst = 0.0
    for q in keys:
        dot = abs(sum(a * b for a, b in zip(q, ref)))
        dot = max(-1.0, min(1.0, dot))
        worst = max(worst, math.degrees(2.0 * math.acos(dot)))
    return worst


def flatten_translation(buf: bytearray, track) -> int:
    keys = _translation_keys(buf, track)
    if len(keys) < 2:
        return 0
    cx = sum(k[0] for k in keys) / len(keys)
    cy = sum(k[1] for k in keys) / len(keys)
    cz = sum(k[2] for k in keys) / len(keys)
    if not all(math.isfinite(v) for v in (cx, cy, cz)):
        return 0
    base = track.stream_start + track.trans_off
    for i in range(len(keys)):
        struct.pack_into("<3f", buf, base + 12 * i, cx, cy, cz)
    return len(keys)


def flatten_rotation(buf: bytearray, track) -> int:
    keys = _rotation_keys(buf, track)
    if len(keys) < 2:
        return 0
    ref = keys[0]
    aligned = []
    for q in keys:
        if sum(a * b for a, b in zip(q, ref)) < 0.0:
            aligned.append(tuple(-v for v in q))
        else:
            aligned.append(q)
    mx = sum(q[0] for q in aligned) / len(aligned)
    my = sum(q[1] for q in aligned) / len(aligned)
    mz = sum(q[2] for q in aligned) / len(aligned)
    mw = sum(q[3] for q in aligned) / len(aligned)
    norm = math.sqrt(mx * mx + my * my + mz * mz + mw * mw)
    if norm < 1e-6 or not math.isfinite(norm):
        return 0
    mx, my, mz = mx / norm, my / norm, mz / norm
    base = track.stream_start + track.rot_off
    for i in range(len(keys)):
        struct.pack_into("<3f", buf, base + 12 * i, mx, my, mz)
    return len(keys)


def analyze_bytes(data: bytes) -> dict:
    """Conta animacoes que ainda balancam, por grupo, para detectar patches."""
    pkg = UpkPackage(data)
    tracks = list_camera_tracks(pkg)
    groups = {
        "walk": lambda name: "_walk_" in name,
        "run": lambda name: "_run_" in name,
        "idle": is_idle,
        "default": lambda name: name in WALK_RUN_DEFAULT,
        "all": lambda name: True,
    }
    stats = {"tracks": len(tracks), "varying": 0, "groups": {}}
    for key, matcher in groups.items():
        selected = [t for t in tracks if t.layout_ok and matcher(t.sequence_name)]
        flat = 0
        varying = 0
        for track in selected:
            still_moves = False
            if track.trans_keys > 1:
                still_moves = _max_translation_deviation(
                    _translation_keys(data, track)) > 1e-5
            if not still_moves and track.rot_keys > 1:
                still_moves = _max_rotation_deviation(
                    _rotation_keys(data, track)) > 0.05
            if still_moves:
                varying += 1
            else:
                flat += 1
        stats["groups"][key] = {"total": len(selected), "flat": flat, "varying": varying}
        if key == "all":
            stats["varying"] = varying
    # Um pacote original tem walk/run/idle balancando. Se um grupo inteiro
    # remained constant, the file was already modified by this (or another) patch.
    stats["patched"] = any(
        group["total"] >= 5 and group["flat"] == group["total"]
        for name, group in stats["groups"].items()
        if name in ("walk", "run", "idle", "default")
    ) or (stats["tracks"] > 0 and stats["varying"] == 0)
    return stats


def patch_bytes(data: bytes, mode: str, breathing: bool, log=None) -> tuple:
    """Aplica o patch em memoria. Retorna (bytes_novos, relatorio)."""
    if mode not in MODE_LABELS:
        raise PatchError("Modo invalido: %s" % mode)

    try:
        pkg = UpkPackage(data)
    except PatchError:
        raise
    except Exception as exc:
        raise PatchError(
            "Could not read OLGame.upk as UE3 package.\\n\\nError: %s" % exc
        )

    try:
        tracks = list_camera_tracks(pkg)
    except PatchError:
        raise
    except Exception as exc:
        raise PatchError(
            "Could not locate camera animations in OLGame.upk.\\n\\nError: %s" % exc
        )
    if not tracks:
        raise PatchError("No hero animations found in the package.")

    buf = bytearray(data)
    selected = [t for t in tracks if track_matches(t.sequence_name, mode, breathing)]
    patched = 0
    skipped_layout = 0
    trans_flattened = 0
    rot_flattened = 0
    trans_keys = 0
    rot_keys = 0

    for track in selected:
        if not track.layout_ok:
            skipped_layout += 1
            continue
        changed = False
        if track.trans_keys > 1:
            dev = _max_translation_deviation(_translation_keys(buf, track))
            if dev > 1e-5:
                written = flatten_translation(buf, track)
                if written:
                    changed = True
                    trans_flattened += 1
                    trans_keys += written
        if track.rot_keys > 1:
            dev = _max_rotation_deviation(_rotation_keys(buf, track))
            if dev > 0.05:
                written = flatten_rotation(buf, track)
                if written:
                    changed = True
                    rot_flattened += 1
                    rot_keys += written
        if changed:
            patched += 1

    if selected and skipped_layout == len(selected):
        raise PatchError(
            "None of the selected animations use the expected track format "
            "expected. The OLGame.upk may be from another game version."
        )

    # Verificacao: nada selecionado pode continuar balancando.
    for track in selected:
        if not track.layout_ok:
            continue
        if track.trans_keys > 1:
            dev = _max_translation_deviation(_translation_keys(buf, track))
            if dev > 0.01:
                raise PatchError(
                    "Verification failed: %s still has translation bob (%.4f)."
                    % (track.sequence_name, dev)
                )
        if track.rot_keys > 1:
            dev = _max_rotation_deviation(_rotation_keys(buf, track))
            if dev > 0.1:
                raise PatchError(
                    "Verification failed: %s still has rotation bob (%.3f graus)."
                    % (track.sequence_name, dev)
                )

    report = {
        "mode": mode,
        "breathing": bool(breathing),
        "total_tracks": len(tracks),
        "selected": len(selected),
        "patched": patched,
        "skipped_layout": skipped_layout,
        "translation_tracks_flattened": trans_flattened,
        "rotation_tracks_flattened": rot_flattened,
        "translation_keys_written": trans_keys,
        "rotation_keys_written": rot_keys,
    }
    return bytes(buf), report


def _sha1(data: bytes) -> str:
    return hashlib.sha1(data).hexdigest()


def _find_decompress_exe(base_dir: str) -> str:
    """Locates decompress.exe next to the patcher or executable."""
    tried = []
    # Script directory / executable directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    # Quando rodando como PyInstaller onefile, sys.executable é o .exe externo
    exe_dir = os.path.dirname(os.path.abspath(sys.executable))
    candidate_dirs = [base_dir, script_dir, exe_dir]
    seen_dirs = set()
    for d in candidate_dirs:
        if d in seen_dirs:
            continue
        seen_dirs.add(d)
        tried.append(os.path.join(d, DECOMPRESS_NAME))
        if os.path.isfile(os.path.join(d, DECOMPRESS_NAME)):
            return os.path.join(d, DECOMPRESS_NAME)
        tried.append(os.path.join(d, "bin", DECOMPRESS_NAME))
        if os.path.isfile(os.path.join(d, "bin", DECOMPRESS_NAME)):
            return os.path.join(d, "bin", DECOMPRESS_NAME)

    raise PatchError(
        "OLGame.upk is compressed and '%s' was not found.\n\n"
        "Caminhos verificados:\n%s\n\n"
        "Place decompress.exe (Gildor's PackageUnpack, included in the folder "
        "do patcher) in the same folder as this program and try again." % (
            DECOMPRESS_NAME,
            "\n".join("  - " + c for c in tried),
        )
    )


def _run_decompressor(pkg_path: str, base_dir: str, log) -> bytes:
    exe = _find_decompress_exe(base_dir)
    temp_dir = tempfile.mkdtemp(prefix="outlast_headbob_")
    try:
        local_pkg = os.path.join(temp_dir, os.path.basename(pkg_path))
        shutil.copy2(pkg_path, local_pkg)
        out_dir = os.path.join(temp_dir, "out")
        os.makedirs(out_dir, exist_ok=True)

        if log:
            log("OLGame.upk comprimido: descomprimindo com decompress.exe...")

        creationflags = 0x08000000 if os.name == "nt" else 0  # CREATE_NO_WINDOW
        attempts = [
            [exe, "-out=" + out_dir, local_pkg],
            [exe, local_pkg],
        ]
        last_output = ""
        for cmd in attempts:
            try:
                proc = subprocess.run(
                    cmd, cwd=temp_dir, stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT, creationflags=creationflags,
                    timeout=600,
                )
                last_output = (proc.stdout or b"").decode("latin-1", "replace")
            except (OSError, subprocess.SubprocessError) as exc:
                last_output = str(exc)
                continue

            for root, _dirs, files in os.walk(temp_dir):
                for filename in files:
                    if not filename.lower().endswith(".upk"):
                        continue
                    candidate = os.path.join(root, filename)
                    if os.path.abspath(candidate) == os.path.abspath(local_pkg):
                        continue
                    try:
                        with open(candidate, "rb") as handle:
                            candidate_data = handle.read()
                        header = read_package_header(candidate_data)
                    except Exception:
                        continue
                    if not header["compressed"]:
                        if log:
                            log("Descompactado: %s (%d bytes)" %
                                (candidate, len(candidate_data)))
                        return candidate_data

        raise PatchError(
            "Could not decompress OLGame.upk.\n\n"
            "Saída do decompress.exe:\n%s" % (last_output[-1500:] or "(vazia)")
        )
    finally:
        shutil.rmtree(temp_dir, ignore_errors=True)


_PATCHABLE_CACHE = {}


def load_patchable_bytes(path: str, base_dir: str, log=None) -> bytes:
    path = os.path.abspath(path)
    try:
        stat = os.stat(path)
        key = (path, stat.st_size, stat.st_mtime_ns)
    except OSError:
        key = None
    if key is not None and key in _PATCHABLE_CACHE:
        return _PATCHABLE_CACHE[key]

    try:
        with open(path, "rb") as handle:
            data = handle.read()
    except OSError as exc:
        raise PatchError("Could not open OLGame.upk: %s" % exc)

    try:
        header = read_package_header(data)
    except PatchError as exc:
        raise PatchError(
            "Invalid OLGame.upk header (does not look like an Outlast .upk).\\n\\nError: %s" % exc
        )
    except Exception as exc:
        raise PatchError(
            "Could not read OLGame.upk header.\\n\\nError: %s" % exc
        )
    if header["compressed"]:
        data = _run_decompressor(path, base_dir, log)

    if key is not None:
        _PATCHABLE_CACHE.clear()
        _PATCHABLE_CACHE[key] = data
    return data


def _write_atomic(path: str, data: bytes):
    tmp_path = path + ".new"
    with open(tmp_path, "wb") as handle:
        handle.write(data)
        handle.flush()
        os.fsync(handle.fileno())
    os.replace(tmp_path, path)
    _PATCHABLE_CACHE.clear()

# ---------------------------------------------------------------------------
# Backup / application / restore
# ---------------------------------------------------------------------------


def backup_path_for(pkg_path: str) -> str:
    return pkg_path + ".backup"


def state_path_for(pkg_path: str) -> str:
    return os.path.join(os.path.dirname(os.path.abspath(pkg_path)), STATE_NAME)


def ensure_backup(pkg_path: str, base_dir: str, log=None) -> str:
    """Creates OLGame.upk.backup only once, from the original file."""
    backup = backup_path_for(pkg_path)
    state = state_path_for(pkg_path)

    if os.path.isfile(backup):
        if os.path.getsize(backup) <= 0:
            raise PatchError("Backup exists but is empty. Restore the game via Steam.")
        if log:
            log("Verifying existing backup...")
        try:
            backup_data = load_patchable_bytes(backup, base_dir, log)
            backup_stats = analyze_bytes(backup_data)
        except PatchError:
            raise
        except Exception as exc:
            raise PatchError(
                "Could not read existing backup '%s'.\n\nError: %s"
                % (os.path.basename(backup), exc)
            )
        if backup_stats["patched"]:
            raise PatchError(
                "Backup '%s' appears to already be modified (an entire group of "
                "animations has no bob).\n\nDelete the backup and restore "
                "OLGame.upk via Steam before continuing."
                % os.path.basename(backup)
            )
        return backup

    if os.path.isfile(state):
        raise PatchError(
            "A previous patch record exists, but backup '%s' was not "
            "found.\n\nRestore OLGame.upk via Steam (Verify integrity "
            "of game files) before continuing." % os.path.basename(backup)
        )

    if log:
        log("Verifying original OLGame.upk before creating backup...")
    try:
        data = load_patchable_bytes(pkg_path, base_dir, log)
        stats = analyze_bytes(data)
    except PatchError:
        raise
    except Exception as exc:
        raise PatchError(
            "Could not read OLGame.upk.\n\nError: %s" % exc
        )
    if stats["patched"]:
        raise PatchError(
            "Current OLGame.upk appears to already be modified (an entire group "
            "of animations has no bob) and no backup exists.\n\n"
            "Restore the game via Steam (Verify integrity of game files) "
            "before applying the patch."
        )

    if log:
        log("Creating backup: %s" % os.path.basename(backup))
    shutil.copy2(pkg_path, backup)

    with open(pkg_path, "rb") as handle:
        original_hash = _sha1(handle.read())
    with open(backup, "rb") as handle:
        backup_hash = _sha1(handle.read())
    if original_hash != backup_hash:
        raise PatchError("Failed to create backup (hash mismatch). Nothing was changed.")

    # Reaproveita os bytes ja descomprimidos/analisados na aplicacao seguinte.
    try:
        backup_stat = os.stat(backup)
        _PATCHABLE_CACHE.clear()
        _PATCHABLE_CACHE[(os.path.abspath(backup), backup_stat.st_size,
                          backup_stat.st_mtime_ns)] = data
    except OSError:
        pass

    if log:
        log("Backup created successfully.")
    return backup


def apply_patch(pkg_path: str, mode: str, breathing: bool, base_dir: str, log=None) -> dict:
    if not os.path.isfile(pkg_path):
        raise PatchError("OLGame.upk not found at:\n%s" % pkg_path)
    if not os.access(pkg_path, os.R_OK):
        raise PatchError("No read permission on OLGame.upk.")
    if not os.access(pkg_path, os.W_OK):
        raise PatchError("No write permission on OLGame.upk.")

    backup = backup_path_for(pkg_path)
    state = state_path_for(pkg_path)
    source_data = None

    if os.path.isfile(backup):
        # Backup ja existe: verificar que ele esta limpo (nao modificado).
        if os.path.getsize(backup) <= 0:
            raise PatchError("Backup exists but is empty. Restore the game via Steam.")
        if log:
            log("Verifying existing backup...")
        try:
            backup_data = load_patchable_bytes(backup, base_dir, log)
            backup_stats = analyze_bytes(backup_data)
        except PatchError:
            raise
        except Exception as exc:
            raise PatchError(
                "Could not read existing backup '%s'.\n\nError: %s"
                % (os.path.basename(backup), exc)
            )
        if backup_stats["patched"]:
            raise PatchError(
                "Backup '%s' appears to already be modified (an entire group of "
                "animations has no bob).\n\nDelete the backup and restore "
                "OLGame.upk via Steam before continuing."
                % os.path.basename(backup)
            )

        # Restaurar explicitamente o OLGame.upk a partir do backup, desfazendo
        # qualquer aplicacao anterior antes de aplicar a nova configuracao.
        if log:
            log("Restoring OLGame.upk from backup before applying new configuration...")
        try:
            _write_atomic(pkg_path, backup_data)
        except PermissionError:
            raise PatchError(
                "Could not write OLGame.upk. Close Outlast (and Steam, if "
                "the game is open) and try again."
            )
        except OSError as exc:
            raise PatchError("Failed to restore OLGame.upk from backup:\n%s" % exc)

        # Ja temos os bytes originais (descomprimidos, se necessario) em memoria;
        # reusa-los evita descompactar o backup novamente.
        source_data = backup_data
    else:
        # Nao existe backup ainda: criar a partir do OLGame.upk atual, que deve
        # ser o original do jogo.
        if os.path.isfile(state):
            raise PatchError(
                "A previous patch record exists, but backup '%s' was not "
                "found.\n\nRestore OLGame.upk via Steam (Verify integrity "
                "of game files) before continuing."
                % os.path.basename(backup)
            )

        if log:
            log("Verifying original OLGame.upk before creating backup...")
        try:
            data = load_patchable_bytes(pkg_path, base_dir, log)
            stats = analyze_bytes(data)
        except PatchError:
            raise
        except Exception as exc:
            raise PatchError(
                "Could not read OLGame.upk.\n\nError: %s" % exc
            )
        if stats["patched"]:
            raise PatchError(
                "Current OLGame.upk appears to already be modified (an entire group "
                "of animations has no bob) and no backup exists.\n\n"
                "Restore the game via Steam (Verify integrity of game files) "
                "before applying the patch."
            )

        if log:
            log("Creating backup: %s" % os.path.basename(backup))
        shutil.copy2(pkg_path, backup)

        with open(pkg_path, "rb") as handle:
            original_hash = _sha1(handle.read())
        with open(backup, "rb") as handle:
            backup_hash = _sha1(handle.read())
        if original_hash != backup_hash:
            raise PatchError("Failed to create backup (hash mismatch). Nothing was changed.")

        try:
            backup_stat = os.stat(backup)
            _PATCHABLE_CACHE.clear()
            _PATCHABLE_CACHE[(os.path.abspath(backup), backup_stat.st_size,
                              backup_stat.st_mtime_ns)] = data
        except OSError:
            pass

        if log:
            log("Backup created successfully.")
        source_data = data

    patched_data, report = patch_bytes(source_data, mode, breathing, log)

    if log:
        log("Writing patched OLGame.upk (%d bytes)..." % len(patched_data))
    try:
        _write_atomic(pkg_path, patched_data)
    except PermissionError:
        raise PatchError(
            "Could not write OLGame.upk. Close Outlast (and Steam, if "
            "the game is open) and try again."
        )
    except OSError as exc:
        raise PatchError("Failed to write OLGame.upk:\n%s" % exc)

    state_obj = {
        "app_version": APP_VERSION,
        "applied_at": time.strftime("%Y-%m-%d %H:%M:%S"),
        "mode": mode,
        "mode_label": MODE_LABELS.get(mode, mode),
        "breathing": bool(breathing),
        "backup": os.path.basename(backup),
        "report": report,
    }
    with open(state_path_for(pkg_path), "w", encoding="utf-8") as handle:
        json.dump(state_obj, handle, ensure_ascii=False, indent=2)

    if log:
        log("")
        log("Patch applied successfully!")
        log("  Animations selected : %d" % report["selected"])
        log("  Animations modified  : %d" % report["patched"])
        log("  Translation keys     : %d" % report["translation_keys_written"])
        log("  Rotation keys        : %d" % report["rotation_keys_written"])
        if report["skipped_layout"]:
            log("  Skipped (layout)     : %d" % report["skipped_layout"])
        log("")
        log("\nOriginal backup at: %s" % os.path.basename(backup))
    return report


def restore_original(pkg_path: str, log=None) -> None:
    backup = backup_path_for(pkg_path)
    if not os.path.isfile(backup):
        raise PatchError(
            "Backup '%s' not found. Nothing to restore."
            % os.path.basename(backup)
        )
    try:
        os.replace(backup, pkg_path)
    except PermissionError:
        raise PatchError(
            "Could not restore. Close Outlast and try again."
        )
    except OSError as exc:
        raise PatchError("Failed to restore OLGame.upk:\n%s" % exc)
    _PATCHABLE_CACHE.clear()
    state = state_path_for(pkg_path)
    if os.path.isfile(state):
        try:
            os.remove(state)
        except OSError:
            pass
    if log:
        log("Original file restored (backup renamed to OLGame.upk).")


def package_status(pkg_path: str) -> dict:
    backup = backup_path_for(pkg_path)
    compressed = None
    if os.path.isfile(pkg_path):
        try:
            with open(pkg_path, "rb") as handle:
                compressed = read_package_header(handle.read(64))["compressed"]
        except Exception:
            compressed = None
    return {
        "exists": os.path.isfile(pkg_path),
        "size": os.path.getsize(pkg_path) if os.path.isfile(pkg_path) else 0,
        "compressed": compressed,
        "backup": os.path.isfile(backup),
        "backup_size": os.path.getsize(backup) if os.path.isfile(backup) else 0,
        "state": os.path.isfile(state_path_for(pkg_path)),
    }

# ---------------------------------------------------------------------------
# Interface grafica
# ---------------------------------------------------------------------------


def _script_dir() -> str:
    return os.path.dirname(os.path.abspath(__file__))


def _default_package_path() -> str:
    candidate = os.path.join(_script_dir(), PACKAGE_NAME)
    if os.path.isfile(candidate):
        return candidate
    return os.path.join(os.getcwd(), PACKAGE_NAME)


class PatcherGUI:
    def __init__(self, root, package_path: str):
        import tkinter as tk
        from tkinter import ttk, messagebox, scrolledtext

        self.tk = tk
        self.ttk = ttk
        self.messagebox = messagebox
        self.scrolledtext = scrolledtext
        self.root = root
        self.package_path = os.path.abspath(package_path)
        self.base_dir = _script_dir()
        self.busy = False
        self.queue = queue.Queue()
        self.mode_var = tk.StringVar(value="default")
        self.breathing_var = tk.BooleanVar(value=True)

        root.title(APP_TITLE)
        root.geometry("820x720")
        root.minsize(740, 560)

        self._build()
        self.refresh_status()
        root.after(120, self._poll_queue)

    # -- construcao ------------------------------------------------------
    def _build(self):
        tk, ttk = self.tk, self.ttk
        outer = ttk.Frame(self.root, padding=14)
        outer.pack(fill="both", expand=True)

        title = ttk.Label(outer, text=APP_TITLE, font=("Segoe UI", 16, "bold"))
        title.pack(anchor="w")
        subtitle = ttk.Label(
            outer,
            text="Removes camera shake (head bob) from Miles's animations inside "
                 "OLGame.upk.",
            wraplength=780, justify="left",
        )
        subtitle.pack(anchor="w", pady=(2, 10))

        file_box = ttk.LabelFrame(outer, text="File", padding=10)
        file_box.pack(fill="x", pady=(0, 10))
        self.file_label = ttk.Label(file_box, text=self.package_path, wraplength=760)
        self.file_label.pack(anchor="w")
        self.status_label = ttk.Label(file_box, text="", foreground="#555555")
        self.status_label.pack(anchor="w", pady=(4, 0))

        bob_box = ttk.LabelFrame(outer, text="Idle camera shake (breathing)", padding=10)
        bob_box.pack(fill="x", pady=(0, 10))
        self.breathing_check = ttk.Checkbutton(
            bob_box, text="Remove breathing head bob?  (recommended)",
            variable=self.breathing_var, command=self._refresh_summary,
        )
        self.breathing_check.pack(anchor="w")
        breathing_desc = ttk.Label(
            bob_box, text=BREATHING_DESCRIPTION, wraplength=740,
            justify="left", foreground="#444444",
        )
        breathing_desc.pack(anchor="w", padx=(22, 0), pady=(2, 0))

        mode_box = ttk.LabelFrame(outer, text="Head bob removal mode", padding=10)
        mode_box.pack(fill="both", expand=False, pady=(0, 10))
        for mode in MODE_ORDER:
            frame = ttk.Frame(mode_box)
            frame.pack(fill="x", anchor="w", pady=(4, 4))
            radio = ttk.Radiobutton(
                frame, text=MODE_LABELS[mode], value=mode,
                variable=self.mode_var, command=self._refresh_summary,
            )
            radio.pack(anchor="w")
            desc = ttk.Label(
                frame, text=MODE_DESCRIPTIONS[mode], wraplength=720,
                justify="left", foreground="#444444",
            )
            desc.pack(anchor="w", padx=(22, 0), pady=(1, 0))

        self.summary_label = ttk.Label(
            outer, text="", foreground="#0b5394", wraplength=780, justify="left"
        )
        self.summary_label.pack(anchor="w", pady=(0, 8))
        self._refresh_summary()

        buttons = ttk.Frame(outer)
        buttons.pack(fill="x", pady=(2, 10))
        self.apply_button = ttk.Button(
            buttons, text="Apply changes", command=self.on_apply,
            style="Accent.TButton",
        )
        self.apply_button.pack(side="left")
        self.restore_button = ttk.Button(
            buttons, text="Restore original file", command=self.on_restore
        )
        self.restore_button.pack(side="left", padx=(8, 0))
        self.quit_button = ttk.Button(buttons, text="Quit", command=self.on_quit)
        self.quit_button.pack(side="right")

        log_box = ttk.LabelFrame(outer, text="Log", padding=6)
        log_box.pack(fill="both", expand=True)
        self.log_text = self.scrolledtext.ScrolledText(
            log_box, height=7, wrap="word", state="disabled",
            font=("Consolas", 9),
        )
        self.log_text.pack(fill="both", expand=True)

        try:
            style = ttk.Style()
            style.configure("Accent.TButton", font=("Segoe UI", 9, "bold"))
        except Exception:
            pass

    # -- utilidades ------------------------------------------------------
    def _log_thread(self, message: str):
        self.queue.put(("log", message))

    def log(self, message: str):
        self.log_text.configure(state="normal")
        self.log_text.insert("end", message + "\n")
        self.log_text.see("end")
        self.log_text.configure(state="disabled")

    def refresh_status(self):
        status = package_status(self.package_path)
        if not status["exists"]:
            self.status_label.configure(
                text="OLGame.upk NOT found in this folder. Place the patcher "
                     "inside CookedPCConsole.", foreground="#b00020"
            )
            return
        parts = ["OLGame.upk: %.1f MB" % (status["size"] / (1024 * 1024))]
        if status.get("compressed") is True:
            parts.append("compressed (will be decompressed on apply)")
        elif status.get("compressed") is False:
            parts.append("uncompressed")
        if status["backup"]:
            parts.append("Backup: OK (%.1f MB)" % (status["backup_size"] / (1024 * 1024)))
        else:
            parts.append("Backup: will be created on first application")
        if status["state"]:
            try:
                with open(state_path_for(self.package_path), "r", encoding="utf-8") as handle:
                    state = json.load(handle)
                parts.append("Current patch: %s%s" % (
                    state.get("mode_label", state.get("mode", "?")),
                    " + breathing" if state.get("breathing") else "",
                ))
            except Exception:
                parts.append("Patch applied")
        else:
            parts.append("Patch: not applied")
        self.status_label.configure(text="   |   ".join(parts), foreground="#333333")

    def _refresh_summary(self):
        mode = self.mode_var.get()
        breathing = bool(self.breathing_var.get())
        counts = {
            "default": (12, 36),
            "walk_run_all": (51, 74),
            "walk": (41, 64),
            "run": (10, 34),
            "all": (360, 360),
        }
        without_idle, with_idle = counts.get(mode, (0, 0))
        total = with_idle if breathing else without_idle
        extra = " + breathing" if breathing else ""
        self.summary_label.configure(
            text="Selected: %s%s  (~%d animations)." %
                 (MODE_LABELS[mode], extra, total)
        )

    def _set_busy(self, busy: bool):
        self.busy = busy
        state = "disabled" if busy else "normal"
        for widget in (self.apply_button, self.restore_button, self.quit_button):
            widget.configure(state=state)
        self.breathing_check.configure(state=state)
        self.root.configure(cursor="watch" if busy else "")

    # -- acoes -----------------------------------------------------------
    def on_apply(self):
        if self.busy:
            return
        if not os.path.isfile(self.package_path):
            self.messagebox.showerror(APP_TITLE, "OLGame.upk not found in this folder.")
            return
        mode = self.mode_var.get()
        breathing = bool(self.breathing_var.get())
        total = self.summary_label.cget("text")
        answer = self.messagebox.askyesno(
            APP_TITLE,
            "Apply changes?\n\n%s\n\nA backup of the original OLGame.upk will be "
            "created (if it doesn't exist yet). If a backup already exists, the "
            "current file will be restored from it before applying the new "
            "configuration. Close the game before continuing." % total,
        )
        if not answer:
            return
        self._set_busy(True)
        self.log("")
        self.log("=== Applying patch ===")
        threading.Thread(
            target=self._apply_worker, args=(mode, breathing), daemon=True
        ).start()

    def _apply_worker(self, mode, breathing):
        try:
            apply_patch(
                self.package_path, mode, breathing, self.base_dir,
                log=self._log_thread,
            )
            self.queue.put(("apply_done", None))
        except PatchError as exc:
            self.queue.put(("error", str(exc)))
        except Exception:
            self.queue.put(("error", traceback.format_exc()))
        finally:
            self.queue.put(("busy", False))

    def on_restore(self):
        if self.busy:
            return
        backup = backup_path_for(self.package_path)
        if not os.path.isfile(backup):
            self.messagebox.showinfo(
                APP_TITLE, "No backup (OLGame.upk.backup) to restore."
            )
            return
        answer = self.messagebox.askyesno(
            APP_TITLE,
            "Restore original OLGame.upk?\n\nThe backup will be renamed to "
            "OLGame.upk, replacing the modified file. Close the game before.",
        )
        if not answer:
            return
        self._set_busy(True)
        self.log("")
        self.log("=== Restoring original file ===")
        threading.Thread(target=self._restore_worker, daemon=True).start()

    def _restore_worker(self):
        try:
            restore_original(self.package_path, log=self._log_thread)
            self.queue.put(("restore_done", None))
        except PatchError as exc:
            self.queue.put(("error", str(exc)))
        except Exception:
            self.queue.put(("error", traceback.format_exc()))
        finally:
            self.queue.put(("busy", False))

    def on_quit(self):
        if self.busy:
            self.messagebox.showinfo(APP_TITLE, "Please wait for the operation to finish.")
            return
        self.root.destroy()

    # -- fila de mensagens ----------------------------------------------
    def _poll_queue(self):
        try:
            while True:
                kind, payload = self.queue.get_nowait()
                if kind == "log":
                    self.log(payload)
                elif kind == "error":
                    self.log("ERRO: " + payload)
                    self.messagebox.showerror(APP_TITLE, payload)
                    self.refresh_status()
                elif kind == "apply_done":
                    self.log("Done.")
                    self.messagebox.showinfo(
                        APP_TITLE,
                        "Patch applied successfully!\n\nOpen the game and test it. "
                        "To revert, use 'Restore original file'.",
                    )
                    self.refresh_status()
                elif kind == "restore_done":
                    self.log("Restore complete.")
                    self.messagebox.showinfo(
                        APP_TITLE,
                        "Original OLGame.upk restored successfully.",
                    )
                    self.refresh_status()
                elif kind == "busy":
                    self._set_busy(bool(payload))
        except queue.Empty:
            pass
        self.root.after(120, self._poll_queue)

# ---------------------------------------------------------------------------
# CLI (para testes e uso avancado)
# ---------------------------------------------------------------------------


def run_cli(args) -> int:
    package = os.path.abspath(args.package or _default_package_path())
    base_dir = _script_dir()
    log = print

    try:
        if args.restore:
            restore_original(package, log=log)
            return 0

        if args.analyze:
            data = load_patchable_bytes(package, base_dir, log)
            stats = analyze_bytes(data)
            print("Hero animations : %d" % stats["tracks"])
            print("With bob          : %d" % stats["varying"])
            return 0

        if not args.mode:
            print("ERROR: specify --mode (%s) or use --analyze/--restore." %
                  ", ".join(MODE_ORDER))
            return 2

        if args.apply:
            apply_patch(package, args.mode, args.breathing, base_dir, log=log)
            return 0

        output = os.path.abspath(args.output or (package + ".patched"))
        data = load_patchable_bytes(package, base_dir, log)
        patched, report = patch_bytes(data, args.mode, args.breathing, log)
        with open(output, "wb") as handle:
            handle.write(patched)
        print("")
        print("Patch written to: %s (%d bytes)" % (output, len(patched)))
        for key, value in report.items():
            print("  %-32s %s" % (key, value))
        return 0
    except PatchError as exc:
        print("ERROR: %s" % exc, file=sys.stderr)
        return 1


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(
        description="Remove o head bob do Outlast editando OLGame.upk.",
    )
    parser.add_argument("--cli", action="store_true", help="uses the command line")
    parser.add_argument("--package", help="path to OLGame.upk")
    parser.add_argument("--mode", choices=MODE_ORDER, help="removal mode")
    parser.add_argument("--breathing", action="store_true",
                        help="also removes breathing shake (idle)")
    parser.add_argument("--output", help="writes patch to another file (does not touch the original)")
    parser.add_argument("--apply", action="store_true",
                        help="applies to OLGame.upk (creates backup automatically)")
    parser.add_argument("--restore", action="store_true", help="restores the backup")
    parser.add_argument("--analyze", action="store_true", help="shows package statistics")
    args = parser.parse_args(argv)

    if args.cli or args.mode or args.apply or args.restore or args.analyze:
        return run_cli(args)

    try:
        import tkinter as tk
    except ImportError:
        print("tkinter is not available. Use the --cli mode.", file=sys.stderr)
        return 1

    root = tk.Tk()
    PatcherGUI(root, args.package or _default_package_path())
    root.mainloop()
    return 0


if __name__ == "__main__":
    sys.exit(main())
