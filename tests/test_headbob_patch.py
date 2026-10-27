"""Tests for the Outlast head-bob analysis and patcher.

Run with:
    python3 -m unittest discover -s tests -v
"""

from __future__ import annotations

import os
import sys
import tempfile
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))

from outlast_upk import Package  # noqa: E402
import headbob_patch as hb  # noqa: E402

INPUT = os.path.join(ROOT, "upk", "unpacked", "OLGame.upk")


@unittest.skipUnless(os.path.exists(INPUT), "unpacked OLGame.upk is not available")
class HeadBobTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.pkg = Package(INPUT)
        cls.rows = hb.collect(
            cls.pkg,
            animsets=hb.DEFAULT_ANIMSETS,
            bone="Hero-Camera",
            pattern=hb.MODE_PATTERNS["walk-run"],
        )

    def test_package_header(self):
        summary = self.pkg.summary()
        self.assertEqual(summary["version"], 868)
        self.assertEqual(summary["licensee"], 3)
        self.assertFalse(summary["compressed"])
        self.assertEqual(summary["exports"], 14449)

    def test_camera_bone_is_configured(self):
        camera = self.pkg.export_by_name("Default__OLHeroCamera", "OLHeroCamera")
        self.assertEqual(
            self.pkg.read_name(self.pkg.property(camera, "CameraBoneName")),
            "Hero-Camera",
        )
        animset = self.pkg.export_by_name("Hero-01_AS", "AnimSet")
        self.assertIn("Hero-Camera", self.pkg.animset_track_bones(animset))
        self.assertIn(
            "Hero-Camera",
            self.pkg.read_name_array(self.pkg.property(animset, "UseTranslationBoneNames")),
        )

    def test_walk_and_run_have_camera_bob(self):
        names = {row[0].name for row in self.rows}
        self.assertIn("player_walk_forward", names)
        self.assertIn("player_run_forward", names)
        for row in self.rows:
            info = row[0]
            if info.name in ("player_walk_forward", "player_run_forward"):
                self.assertGreater(info.translation_amplitude[2], 1.0)
                self.assertGreater(info.rotation_amplitude_deg, 0.5)

    def test_patch_changes_only_camera_track_bytes(self):
        pkg = Package(INPUT)
        rows = hb.collect(
            pkg,
            animsets=hb.DEFAULT_ANIMSETS,
            bone="Hero-Camera",
            pattern=hb.MODE_PATTERNS["walk-run"],
        )
        before = bytes(pkg.data)
        report = hb.patch(
            pkg,
            rows,
            translation="flatten",
            rotation="flatten",
            dry_run=False,
        )
        after = bytes(pkg.data)
        self.assertEqual(len(before), len(after))
        self.assertEqual(report.modified, len(rows))
        self.assertGreater(report.changed_bytes, 0)

        allowed = []
        for row in rows:
            info = row[0]
            allowed.append(
                (info.trans_byte_offset, info.trans_byte_offset + info.translation_count * 12)
            )
            allowed.append(
                (info.rot_byte_offset, info.rot_byte_offset + info.rotation_count * 12)
            )

        bad = [
            offset
            for offset, (a, b) in enumerate(zip(before, after))
            if a != b and not any(start <= offset < end for start, end in allowed)
        ]
        self.assertEqual(bad, [])

    def test_written_package_validates(self):
        pkg = Package(INPUT)
        rows = hb.collect(
            pkg,
            animsets=hb.DEFAULT_ANIMSETS,
            bone="Hero-Camera",
            pattern=hb.MODE_PATTERNS["walk-run"],
        )
        hb.patch(pkg, rows, translation="flatten", rotation="flatten", dry_run=False)
        with tempfile.TemporaryDirectory() as tmp:
            out = os.path.join(tmp, "OLGame_fixed.upk")
            with open(out, "wb") as fh:
                fh.write(pkg.data)
            errors = hb.validate(
                out,
                rows,
                bone="Hero-Camera",
                translation="flatten",
                rotation="flatten",
            )
            self.assertEqual(errors, [])
            fixed = Package(out)
            self.assertEqual(len(fixed.data), len(pkg.data))
            # A non-selected animation must be byte-identical.
            original = Package(INPUT)
            hobble = next(
                s
                for s in original.animset_sequences(original.export_by_name("Hero-01_AS", "AnimSet"))
                if original.anim_sequence_name(s) == "player_walk_hobble_forward"
            )
            a = original.data[hobble.serial_offset : hobble.serial_offset + hobble.serial_size]
            b = fixed.data[hobble.serial_offset : hobble.serial_offset + hobble.serial_size]
            self.assertEqual(a, b)


if __name__ == "__main__":
    unittest.main()
