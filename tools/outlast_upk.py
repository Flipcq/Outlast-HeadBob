"""Minimal reader for the Unreal Engine 3 package used by Outlast (UE3 868 / licensee 3).

Only what is needed to inspect OLGame.upk and to locate the compressed animation
tracks of the Hero skeleton is implemented.  Patches made by the other scripts
are same-size in-place edits; this module never rebuilds a package.

Layout notes for this specific package (verified against upk/unpacked/OLGame.upk):

    header:
        0x00 u32 tag (0x9E2A83C1)
        0x04 u16 version (868)
        0x06 u16 licensee (3)
        0x08 i32 header size
        0x0C FString package name ("None")
        ...  u32 package flags
             i32 NameCount, NameOffset
             i32 ExportCount, ExportOffset
             i32 ImportCount, ImportOffset
             i32 DependsOffset
             ...

    name entry:
        FString, then 8 bytes of flags (UE3 stores 64-bit object flags)

    import:
        FName ClassPackage, FName ClassName, i32 OuterIndex, FName ObjectName

    export (version >= 475):
        i32 ClassIndex, i32 SuperIndex, i32 OuterIndex
        FName ObjectName
        i32 Archetype
        u32 ObjectFlags, u32 ObjectFlags2
        i32 SerialSize, i32 SerialOffset
        i32 ExportFlags
        i32 NetObjectCount + 4*count bytes
        FGuid (16 bytes)
        i32 U3unk6C

    tagged property:
        FName Name, FName Type, i32 Size, i32 ArrayIndex
        StructProperty -> FName StructName
        BoolProperty   -> u8 value (Size is 0)
        ByteProperty   -> FName EnumName
        ArrayProperty  -> no extra field in this package
        then Size bytes of value
"""

from __future__ import annotations

import struct
from dataclasses import dataclass
from typing import Dict, Iterable, List, Optional, Tuple

PACKAGE_TAG = 0x9E2A83C1
UE3_VERSION = 868
UE3_LICENSEE = 3

# Package flag that tells UE3 the package chunks are LZO compressed.
PKG_COMPRESSED = 0x02000000


def _read_fstring(data: bytes, offset: int) -> Tuple[str, int]:
    """Read a UE3 FString. Returns (text, offset_after_string)."""
    length = struct.unpack_from("<i", data, offset)[0]
    offset += 4
    if length == 0:
        return "", offset
    if length > 0:
        raw = data[offset : offset + length - 1]
        return raw.decode("latin-1"), offset + length
    count = -length
    raw = data[offset : offset + 2 * (count - 1)]
    return raw.decode("utf-16-le"), offset + 2 * count


def _read_fname(data: bytes, offset: int, names: List[str]) -> Tuple[str, int, int]:
    """Read an FName (index + number). Returns (display_name, index, offset)."""
    index, number = struct.unpack_from("<ii", data, offset)
    if 0 <= index < len(names):
        base = names[index]
    else:
        base = f"<name:{index}>"
    name = base if number == 0 else f"{base}_{number - 1}"
    return name, index, offset + 8


@dataclass
class Import:
    class_package: str
    class_name: str
    outer_index: int
    object_name: str

    @property
    def resolved_class(self) -> str:
        # For class objects ClassName is literally "Class"; the real class is
        # stored in ObjectName (e.g. "AnimSet").
        return self.object_name if self.class_name == "Class" else self.class_name


@dataclass
class Export:
    index: int
    class_index: int
    super_index: int
    outer_index: int
    name_index: int
    name: str
    archetype: int
    object_flags: int
    object_flags2: int
    serial_size: int
    serial_offset: int
    export_flags: int
    net_object_count: int


@dataclass
class Property:
    name: str
    type: str
    size: int
    array_index: int
    tag_offset: int
    value_offset: int
    struct_name: Optional[str] = None
    bool_value: Optional[int] = None
    enum_name: Optional[str] = None

    @property
    def end(self) -> int:
        return self.value_offset + self.size



class Package:
    """Read a cooked Outlast UE3 package."""

    def __init__(self, path: str):
        self.path = path
        with open(path, "rb") as fh:
            self.data = fh.read()
        if len(self.data) < 0x40:
            raise ValueError("file is too small to be a UE3 package")
        tag, version, licensee = struct.unpack_from("<IHH", self.data, 0)
        if tag != PACKAGE_TAG:
            raise ValueError(f"unsupported package tag 0x{tag:08X}")
        self.version = version
        self.licensee = licensee
        self.header_size = struct.unpack_from("<i", self.data, 8)[0]
        self.package_name, after_name = _read_fstring(self.data, 12)
        (self.package_flags,) = struct.unpack_from("<I", self.data, after_name)
        (
            self.name_count,
            self.name_offset,
            self.export_count,
            self.export_offset,
            self.import_count,
            self.import_offset,
            self.depends_offset,
        ) = struct.unpack_from("<7i", self.data, after_name + 4)

        self.names = self._load_names()
        self.imports = self._load_imports()
        self.exports = self._load_exports()
        self._exports_by_name: Dict[str, List[Export]] = {}
        for export in self.exports:
            self._exports_by_name.setdefault(export.name, []).append(export)

    # ------------------------------------------------------------------ tables
    def _load_names(self) -> List[str]:
        names: List[str] = []
        offset = self.name_offset
        for _ in range(self.name_count):
            text, offset = _read_fstring(self.data, offset)
            names.append(text)
            offset += 8  # 64-bit name flags (UE3 >= 195)
        return names

    def _load_imports(self) -> List[Import]:
        imports: List[Import] = []
        offset = self.import_offset
        for _ in range(self.import_count):
            class_package, _, offset = _read_fname(self.data, offset, self.names)
            class_name, _, offset = _read_fname(self.data, offset, self.names)
            (outer_index,) = struct.unpack_from("<i", self.data, offset)
            offset += 4
            object_name, _, offset = _read_fname(self.data, offset, self.names)
            imports.append(Import(class_package, class_name, outer_index, object_name))
        return imports

    def _load_exports(self) -> List[Export]:
        exports: List[Export] = []
        offset = self.export_offset
        for index in range(self.export_count):
            (
                class_index,
                super_index,
                outer_index,
                name_index,
                _name_number,
                archetype,
                object_flags,
                object_flags2,
                serial_size,
                serial_offset,
                export_flags,
                net_object_count,
            ) = struct.unpack_from("<12i", self.data, offset)
            offset += 48
            if net_object_count:
                offset += 4 * net_object_count
            offset += 16 + 4  # FGuid + U3unk6C
            exports.append(
                Export(
                    index=index,
                    class_index=class_index,
                    super_index=super_index,
                    outer_index=outer_index,
                    name_index=name_index,
                    name=self.names[name_index]
                    if 0 <= name_index < len(self.names)
                    else f"<name:{name_index}>",
                    archetype=archetype,
                    object_flags=object_flags,
                    object_flags2=object_flags2,
                    serial_size=serial_size,
                    serial_offset=serial_offset,
                    export_flags=export_flags,
                    net_object_count=net_object_count,
                )
            )
        return exports

    # ---------------------------------------------------------------- helpers
    def fname_at(self, offset: int) -> Tuple[str, int, int]:
        return _read_fname(self.data, offset, self.names)

    def object_name(self, package_index: int) -> str:
        """Resolve a UE3 package index to a readable object name."""
        if package_index == 0:
            return "PACKAGE"
        if package_index < 0:
            idx = -package_index - 1
            if 0 <= idx < len(self.imports):
                return f"IMP:{self.imports[idx].object_name}"
            return f"IMP?{idx}"
        idx = package_index - 1
        if 0 <= idx < len(self.exports):
            return f"EXP:{self.exports[idx].name}"
        return f"EXP?{idx}"

    def export_class_name(self, export: Export) -> str:
        if export.class_index < 0:
            idx = -export.class_index - 1
            if 0 <= idx < len(self.imports):
                return self.imports[idx].resolved_class
            return f"<class:{export.class_index}>"
        idx = export.class_index - 1
        if 0 <= idx < len(self.exports):
            return self.exports[idx].name
        return f"<class:{export.class_index}>"

    def find_exports(
        self, *, name: Optional[str] = None, class_name: Optional[str] = None
    ) -> List[Export]:
        candidates = self.exports
        if name is not None:
            candidates = [e for e in candidates if e.name == name]
        if class_name is not None:
            candidates = [e for e in candidates if self.export_class_name(e) == class_name]
        return list(candidates)

    def export_by_name(self, name: str, class_name: Optional[str] = None) -> Export:
        matches = self.find_exports(name=name, class_name=class_name)
        if not matches:
            raise KeyError(f"export {name!r} (class {class_name!r}) not found")
        return matches[0]

    def iter_anim_sets(self) -> Iterable[Export]:
        for export in self.exports:
            if self.export_class_name(export) == "AnimSet":
                yield export

    def is_compressed_package(self) -> bool:
        return bool(self.package_flags & PKG_COMPRESSED)

    def summary(self) -> Dict[str, object]:
        return {
            "path": self.path,
            "version": self.version,
            "licensee": self.licensee,
            "package_name": self.package_name,
            "package_flags": f"0x{self.package_flags:08X}",
            "compressed": self.is_compressed_package(),
            "names": self.name_count,
            "imports": len(self.imports),
            "exports": len(self.exports),
        }

    # --------------------------------------------------------------- properties
    def properties_and_end(self, export: Export) -> Tuple[List[Property], int]:
        """Parse the tagged property stream of an export.

        Outlast objects have a 4-byte prefix before the first property tag
        (verified on OLHero, OLHeroCamera, AnimSet, AnimSequence and AnimNode
        objects).  The returned ``end`` is the offset right after the "None"
        terminator, where native serialized data starts.
        """
        offset = export.serial_offset + 4
        end = export.serial_offset + export.serial_size
        props: List[Property] = []
        while offset + 24 <= end:
            name, name_index, _ = self.fname_at(offset)
            if name == "None" or name_index == 0:
                return props, offset + 8
            type_name, _, _ = self.fname_at(offset + 8)
            size, array_index = struct.unpack_from("<ii", self.data, offset + 16)
            value_offset = offset + 24
            struct_name = None
            bool_value = None
            enum_name = None
            if type_name == "StructProperty":
                struct_name, _, _ = self.fname_at(value_offset)
                value_offset += 8
            elif type_name == "BoolProperty":
                bool_value = self.data[value_offset]
                value_offset += 1
                size = 0
            elif type_name == "ByteProperty":
                enum_name, _, _ = self.fname_at(value_offset)
                value_offset += 8
            # NOTE: ArrayProperty has no InnerType FName in this package.
            props.append(
                Property(
                    name=name,
                    type=type_name,
                    size=size,
                    array_index=array_index,
                    tag_offset=offset,
                    value_offset=value_offset,
                    struct_name=struct_name,
                    bool_value=bool_value,
                    enum_name=enum_name,
                )
            )
            offset = value_offset + size
        return props, offset

    def properties(self, export: Export) -> List[Property]:
        return self.properties_and_end(export)[0]

    def property(self, export: Export, name: str, array_index: int = 0) -> Property:
        for prop in self.properties(export):
            if prop.name == name and prop.array_index == array_index:
                return prop
        raise KeyError(f"property {name!r} not found in export {export.index} {export.name}")

    # ---------------------------------------------------------------- values
    def read_int(self, prop: Property) -> int:
        return struct.unpack_from("<i", self.data, prop.value_offset)[0]

    def read_float(self, prop: Property) -> float:
        return struct.unpack_from("<f", self.data, prop.value_offset)[0]

    def read_bool(self, prop: Property) -> bool:
        if prop.type != "BoolProperty":
            raise TypeError(f"{prop.name} is {prop.type}, not BoolProperty")
        return bool(prop.bool_value)

    def read_name(self, prop: Property) -> str:
        return self.fname_at(prop.value_offset)[0]

    def read_name_array(self, prop: Property) -> List[str]:
        count = self.read_int(prop)
        names: List[str] = []
        offset = prop.value_offset + 4
        for _ in range(count):
            name, _, _ = self.fname_at(offset)
            names.append(name)
            offset += 8
        return names

    def read_int_array(self, prop: Property) -> List[int]:
        count = self.read_int(prop)
        return list(struct.unpack_from(f"<{count}i", self.data, prop.value_offset + 4))

    def read_object_array(self, prop: Property) -> List[int]:
        return self.read_int_array(prop)

    # ---------------------------------------------------------------- anim data
    def animset_track_bones(self, animset: Export) -> List[str]:
        return self.read_name_array(self.property(animset, "TrackBoneNames"))

    def animset_sequences(self, animset: Export) -> List[Export]:
        refs = self.read_object_array(self.property(animset, "Sequences"))
        sequences: List[Export] = []
        for ref in refs:
            if ref <= 0:
                continue
            index = ref - 1
            if 0 <= index < len(self.exports):
                sequences.append(self.exports[index])
        return sequences

    def anim_sequence_name(self, sequence: Export) -> str:
        return self.read_name(self.property(sequence, "SequenceName"))

    def anim_camera_track(
        self, sequence: Export, bone_index: int
    ) -> Tuple[
        List[Tuple[float, float, float]],
        List[Tuple[float, float, float]],
        Dict[str, object],
    ]:
        """Return camera translation/rotation keys plus byte-level locations.

        UE3 stores four ints per bone in ``CompressedTrackOffsets``:
            translation offset, translation key count,
            rotation offset, rotation key count

        For Outlast every Hero sequence uses:
          * TranslationCompressionFormat = ACF_None (uncompressed 3x float32)
          * RotationCompressionFormat    = ACF_Float96NoW (3x float32, W rebuilt)
        Both key types are therefore 12 bytes.
        """
        props, tag_end = self.properties_and_end(sequence)
        by_name = {p.name: p for p in props}
        if "CompressedTrackOffsets" not in by_name:
            raise ValueError(f"{sequence.name} has no CompressedTrackOffsets")
        offsets = self.read_int_array(by_name["CompressedTrackOffsets"])
        track = bone_index * 4
        if track + 4 > len(offsets):
            raise ValueError(
                f"{sequence.name}: only {len(offsets) // 4} tracks, "
                f"bone {bone_index} out of range"
            )
        trans_offset, trans_count, rot_offset, rot_count = offsets[track : track + 4]
        translation_format, stream_size = struct.unpack_from("<ii", self.data, tag_end)
        if translation_format != 0:
            raise ValueError(
                f"{sequence.name}: unsupported translation compression format "
                f"{translation_format} (expected ACF_None=0)"
            )
        rot_prop = by_name.get("RotationCompressionFormat")
        if rot_prop is not None:
            rot_format = self.read_name(rot_prop)
            if rot_format not in ("ACF_Float96NoW", "ACF_None"):
                raise ValueError(
                    f"{sequence.name}: unsupported rotation compression format "
                    f"{rot_format} (expected ACF_Float96NoW)"
                )
        stream_base = tag_end + 8
        stream_end = stream_base + stream_size

        def check_range(offset: int, count: int, label: str) -> None:
            if count and (
                offset < 0 or stream_base + offset + count * 12 > stream_end
            ):
                raise ValueError(
                    f"{sequence.name}: {label} track out of bounds "
                    f"(offset={offset}, count={count}, stream={stream_size})"
                )

        check_range(trans_offset, trans_count, "translation")
        check_range(rot_offset, rot_count, "rotation")
        translations = [
            struct.unpack_from("<3f", self.data, stream_base + trans_offset + i * 12)
            for i in range(trans_count)
        ]
        rotations = [
            struct.unpack_from("<3f", self.data, stream_base + rot_offset + i * 12)
            for i in range(rot_count)
        ]
        info = {
            "translation_format": translation_format,
            "stream_size": stream_size,
            "stream_base": stream_base,
            "translation_offset": trans_offset,
            "translation_count": trans_count,
            "rotation_offset": rot_offset,
            "rotation_count": rot_count,
            "tag_end": tag_end,
            "translation_byte_offset": stream_base + trans_offset,
            "rotation_byte_offset": stream_base + rot_offset,
        }
        return translations, rotations, info

        return self.read_int_array(prop)
