#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Outlast - Head Bob Patcher
==========================

Remove o head bob (balanco da camera) do Outlast editando os keyframes da bone
"Hero-Camera" dentro do OLGame.upk (pacote seekfree que contem as animacoes do
Miles).

Como o jogo funciona (resumo):
  * OLPlayerController.GetPlayerViewPoint() chama OLHero.GetCamera() (nativo).
  * OLHeroCamera.Update() le a posicao/rotacao da bone "Hero-Camera" direto da
    animacao (Mesh.GetBoneLocation/GetBoneQuaternion) e aplica shakes/neck offset.
  * Logo, o balanco de caminhada/corrida/respiracao esta gravado nos keyframes de
    translacao (e rotacao) dessa bone nos AnimSequence do AnimSet
    "03_Hero.Hero-01_AS", que vive dentro de OLGame.upk.

O patcher achata (deixa constante) esses keyframes apenas nas animacoes
escolhidas, sem mudar tamanhos, offsets ou qualquer outro dado do pacote.

Uso:
  GUI:  python OutlastHeadBobPatcher.py
  CLI:  python OutlastHeadBobPatcher.py --cli --package OLGame.upk --mode default --breathing

Requisitos:
  * Python 3.8+ (tkinter para a GUI).
  * Se o OLGame.upk estiver comprimido, o "decompress.exe" (Gildor's PackageUnpack,
    incluido nesta pasta) precisa estar ao lado deste script.

O arquivo OLGame.upk original e salvo como "OLGame.upk.backup" na primeira
aplicacao. "Restaurar arquivo original" renomeia o backup de volta.
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
    "default": "Caminhada + Corrida (padrão)",
    "walk_run_all": "Caminhada + Corrida (todas)",
    "walk": "Somente caminhada",
    "run": "Somente corrida",
    "all": "Todas as animações",
}

MODE_DESCRIPTIONS = {
    "default": (
        "Remove o balanço apenas dos ciclos normais de caminhada e corrida "
        "(frente, trás, laterais e variantes na água). Recomendado para jogar "
        "sem enjoo, sem mexer em pulos, quedas ou interações."
    ),
    "walk_run_all": (
        "Remove de TODAS as animações que tenham 'walk' ou 'run' no nome, "
        "incluindo andar agachado, mancando, ferido, escadas, pulos e "
        "transições (qualquer animação com walk/run)."
    ),
    "walk": (
        "Todas as animações de caminhada ('walk'), incluindo variantes "
        "(água, mancando, ferido) e transições."
    ),
    "run": (
        "Todas as animações de corrida ('run'), incluindo variantes "
        "(mancando) e transições."
    ),
    "all": (
        "Remove o balanço de TODAS as animações do Miles (idle, walk, run, "
        "crouch, pulos, quedas, interações, fatalities). Remoção máxima; pode "
        "alterar animações scriptizadas de gameplay."
    ),
}

BREATHING_DESCRIPTION = (
    "Elimina o balanço de respiração quando o Miles está parado (idle), "
    "incluindo agachado, encostado, na cama, dentro do armário e com a câmera "
    "na mão. Recomendado."
)


class PatchError(Exception):
    """Erro esperado, mostrado ao usuario sem traceback."""


def _align4(n: int) -> int:
    return (n + 3) & ~3


def _f32(data: bytes, off: int) -> float:
    return struct.unpack_from("<f", data, off)[0]

# ---------------------------------------------------------------------------
# Leitor de pacotes UE3 (Outlast: versao 868, licensee 3)
# ---------------------------------------------------------------------------


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
    """Le apenas o cabecalho (funciona tambem em pacotes comprimidos)."""
    if len(data) < 64:
        raise PatchError("Arquivo muito pequeno para ser um .upk do Outlast.")
    tag = struct.unpack_from("<I", data, 0)[0]
    if tag != 0x9E2A83C1:
        raise PatchError("Tag de pacote inválida (não parece um .upk UE3).")

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
                "O pacote está comprimido; ele precisa ser descomprimido antes "
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
                raise PatchError("Tabela de nomes invalida no .upk.")
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
            raise PatchError("Não foi possível ler as propriedades do objeto.")
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
        raise PatchError("Array de nomes invalido.")
    out = []
    off = prop["value"] + 4
    for _ in range(count):
        index = struct.unpack_from("<i", data, off)[0]
        if index < 0 or index >= len(pkg.names):
            raise PatchError("Indice de nome invalido.")
        out.append(pkg.names[index])
        off += 8
    return out


def _read_int_array(pkg: UpkPackage, prop) -> list:
    data = pkg.data
    count = struct.unpack_from("<i", data, prop["value"])[0]
    if count < 0 or count > 65536:
        raise PatchError("Array de inteiros invalido.")
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
            "AnimSet '%s' não encontrado no OLGame.upk. "
            "O arquivo pode ser de outra versao do jogo." % ANIMSET_NAME
        )

    data = pkg.data
    props, stop = pkg.parse_properties(animset_export)
    if "TrackBoneNames" not in props:
        raise PatchError("AnimSet sem lista de bones (TrackBoneNames).")
    bone_names = _read_name_array(pkg, props["TrackBoneNames"][0])
    try:
        camera_index = [n.lower() for n in bone_names].index(CAMERA_BONE.lower())
    except ValueError:
        raise PatchError(
            "A bone '%s' não existe no AnimSet. Formato de animação inesperado."
            % CAMERA_BONE
        )

    if "Sequences" not in props:
        raise PatchError("AnimSet sem lista de sequencias.")
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
            layout_error = "tamanho do stream não confere"
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
    raise PatchError("Modo de remoção desconhecido: %s" % mode)


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
    # ficou constante, o arquivo ja foi modificado por este (ou outro) patch.
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

    pkg = UpkPackage(data)
    tracks = list_camera_tracks(pkg)
    if not tracks:
        raise PatchError("Nenhuma animação do herói foi encontrada no pacote.")

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

    # Verificacao: nada selecionado pode continuar balancando.
    for track in selected:
        if not track.layout_ok:
            continue
        if track.trans_keys > 1:
            dev = _max_translation_deviation(_translation_keys(buf, track))
            if dev > 0.01:
                raise PatchError(
                    "Falha na verificação: %s ainda tem bob de translação (%.4f)."
                    % (track.sequence_name, dev)
                )
        if track.rot_keys > 1:
            dev = _max_rotation_deviation(_rotation_keys(buf, track))
            if dev > 0.1:
                raise PatchError(
                    "Falha na verificação: %s ainda tem bob de rotação (%.3f graus)."
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
    candidates = [
        os.path.join(base_dir, DECOMPRESS_NAME),
        os.path.join(base_dir, "bin", DECOMPRESS_NAME),
        os.path.join(os.path.dirname(os.path.abspath(__file__)), DECOMPRESS_NAME),
    ]
    for candidate in candidates:
        if os.path.isfile(candidate):
            return candidate
    raise PatchError(
        "O OLGame.upk está comprimido e o '%s' não foi encontrado.\n\n"
        "Coloque o decompress.exe (Gildor's PackageUnpack, incluido na pasta "
        "do patcher) ao lado deste programa e tente novamente." % DECOMPRESS_NAME
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
            "Não foi possível descomprimir o OLGame.upk.\n\n"
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

    with open(path, "rb") as handle:
        data = handle.read()
    header = read_package_header(data)
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
# Backup / aplicacao / restauracao
# ---------------------------------------------------------------------------


def backup_path_for(pkg_path: str) -> str:
    return pkg_path + ".backup"


def state_path_for(pkg_path: str) -> str:
    return os.path.join(os.path.dirname(os.path.abspath(pkg_path)), STATE_NAME)


def ensure_backup(pkg_path: str, base_dir: str, log=None) -> str:
    """Cria OLGame.upk.backup apenas uma vez, a partir do arquivo original."""
    backup = backup_path_for(pkg_path)
    state = state_path_for(pkg_path)

    if os.path.isfile(backup):
        if os.path.getsize(backup) <= 0:
            raise PatchError("O backup existe mas esta vazio. Restaure o jogo pela Steam.")
        return backup

    if os.path.isfile(state):
        raise PatchError(
            "Existe um registro de patch anterior, mas o backup '%s' não foi "
            "encontrado.\n\nRestaure o OLGame.upk pela Steam (Verificar "
            "integridade dos arquivos) antes de continuar." % os.path.basename(backup)
        )

    if log:
        log("Verificando o OLGame.upk original antes de criar o backup...")
    data = load_patchable_bytes(pkg_path, base_dir, log)
    stats = analyze_bytes(data)
    if stats["patched"]:
        raise PatchError(
            "O OLGame.upk atual parece ja ter sido modificado (um grupo inteiro "
            "de animações está sem balanço) e não existe backup.\n\n"
            "Restaure o jogo pela Steam (Verificar integridade dos arquivos) "
            "antes de aplicar o patch."
        )

    if log:
        log("Criando backup: %s" % os.path.basename(backup))
    shutil.copy2(pkg_path, backup)

    with open(pkg_path, "rb") as handle:
        original_hash = _sha1(handle.read())
    with open(backup, "rb") as handle:
        backup_hash = _sha1(handle.read())
    if original_hash != backup_hash:
        raise PatchError("Falha ao criar o backup (hash diferente). Nada foi alterado.")

    if log:
        log("Backup criado com sucesso.")
    return backup


def apply_patch(pkg_path: str, mode: str, breathing: bool, base_dir: str, log=None) -> dict:
    if not os.path.isfile(pkg_path):
        raise PatchError("OLGame.upk não encontrado em:\n%s" % pkg_path)
    if not os.access(pkg_path, os.R_OK):
        raise PatchError("Sem permissao de leitura no OLGame.upk.")

    backup = ensure_backup(pkg_path, base_dir, log)

    if log:
        log("Lendo o backup original...")
    source_data = load_patchable_bytes(backup, base_dir, log)

    if log:
        log("Aplicando patch (modo=%s, respiração=%s)..." % (mode, "sim" if breathing else "não"))
    patched_data, report = patch_bytes(source_data, mode, breathing, log)

    if log:
        log("Gravando OLGame.upk modificado (%d bytes)..." % len(patched_data))
    try:
        _write_atomic(pkg_path, patched_data)
    except PermissionError:
        raise PatchError(
            "Não foi possível gravar o OLGame.upk. Feche o Outlast (e o Steam, se "
            "estiver com o jogo aberto) e tente novamente."
        )
    except OSError as exc:
        raise PatchError("Falha ao gravar o OLGame.upk:\n%s" % exc)

    state = {
        "app_version": APP_VERSION,
        "applied_at": time.strftime("%Y-%m-%d %H:%M:%S"),
        "mode": mode,
        "mode_label": MODE_LABELS.get(mode, mode),
        "breathing": bool(breathing),
        "backup": os.path.basename(backup),
        "report": report,
    }
    with open(state_path_for(pkg_path), "w", encoding="utf-8") as handle:
        json.dump(state, handle, ensure_ascii=False, indent=2)

    if log:
        log("")
        log("Patch aplicado com sucesso!")
        log("  Animações selecionadas : %d" % report["selected"])
        log("  Animações modificadas  : %d" % report["patched"])
        log("  Keys de translação     : %d" % report["translation_keys_written"])
        log("  Keys de rotação        : %d" % report["rotation_keys_written"])
        if report["skipped_layout"]:
            log("  Ignoradas (layout)     : %d" % report["skipped_layout"])
        log("")
        log("Backup original em: %s" % os.path.basename(backup))
    return report


def restore_original(pkg_path: str, log=None) -> None:
    backup = backup_path_for(pkg_path)
    if not os.path.isfile(backup):
        raise PatchError(
            "Backup '%s' não encontrado. Não há o que restaurar."
            % os.path.basename(backup)
        )
    try:
        os.replace(backup, pkg_path)
    except PermissionError:
        raise PatchError(
            "Não foi possível restaurar. Feche o Outlast e tente novamente."
        )
    except OSError as exc:
        raise PatchError("Falha ao restaurar o OLGame.upk:\n%s" % exc)
    _PATCHABLE_CACHE.clear()
    state = state_path_for(pkg_path)
    if os.path.isfile(state):
        try:
            os.remove(state)
        except OSError:
            pass
    if log:
        log("Arquivo original restaurado (backup renomeado para OLGame.upk).")


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
            text="Remove o balanço da câmera (head bob) das animações do Miles "
                 "dentro do OLGame.upk.",
            wraplength=780, justify="left",
        )
        subtitle.pack(anchor="w", pady=(2, 10))

        file_box = ttk.LabelFrame(outer, text="Arquivo", padding=10)
        file_box.pack(fill="x", pady=(0, 10))
        self.file_label = ttk.Label(file_box, text=self.package_path, wraplength=760)
        self.file_label.pack(anchor="w")
        self.status_label = ttk.Label(file_box, text="", foreground="#555555")
        self.status_label.pack(anchor="w", pady=(4, 0))

        bob_box = ttk.LabelFrame(outer, text="Balanço em repouso (respiração)", padding=10)
        bob_box.pack(fill="x", pady=(0, 10))
        self.breathing_check = ttk.Checkbutton(
            bob_box, text="Remover o head bob de respiração?  (recomendado)",
            variable=self.breathing_var, command=self._refresh_summary,
        )
        self.breathing_check.pack(anchor="w")
        breathing_desc = ttk.Label(
            bob_box, text=BREATHING_DESCRIPTION, wraplength=740,
            justify="left", foreground="#444444",
        )
        breathing_desc.pack(anchor="w", padx=(22, 0), pady=(2, 0))

        mode_box = ttk.LabelFrame(outer, text="Modo de remoção do head bob", padding=10)
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
            buttons, text="Aplicar alteracoes", command=self.on_apply,
            style="Accent.TButton",
        )
        self.apply_button.pack(side="left")
        self.restore_button = ttk.Button(
            buttons, text="Restaurar arquivo original", command=self.on_restore
        )
        self.restore_button.pack(side="left", padx=(8, 0))
        self.quit_button = ttk.Button(buttons, text="Sair", command=self.on_quit)
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
                text="OLGame.upk NÃO encontrado nesta pasta. Coloque o patcher "
                     "dentro de CookedPCConsole.", foreground="#b00020"
            )
            return
        parts = ["OLGame.upk: %.1f MB" % (status["size"] / (1024 * 1024))]
        if status.get("compressed") is True:
            parts.append("comprimido (será descomprimido ao aplicar)")
        elif status.get("compressed") is False:
            parts.append("descomprimido")
        if status["backup"]:
            parts.append("Backup: OK (%.1f MB)" % (status["backup_size"] / (1024 * 1024)))
        else:
            parts.append("Backup: será criado na primeira aplicação")
        if status["state"]:
            try:
                with open(state_path_for(self.package_path), "r", encoding="utf-8") as handle:
                    state = json.load(handle)
                parts.append("Patch atual: %s%s" % (
                    state.get("mode_label", state.get("mode", "?")),
                    " + respiração" if state.get("breathing") else "",
                ))
            except Exception:
                parts.append("Patch aplicado")
        else:
            parts.append("Patch: não aplicado")
        self.status_label.configure(text="   |   ".join(parts), foreground="#333333")

    def _refresh_summary(self):
        mode = self.mode_var.get()
        breathing = bool(self.breathing_var.get())
        counts = {
            "default": (12, 36),
            "walk_run_all": (51, 75),
            "walk": (41, 65),
            "run": (10, 34),
            "all": (360, 360),
        }
        without_idle, with_idle = counts.get(mode, (0, 0))
        total = with_idle if breathing else without_idle
        extra = " + respiração" if breathing else ""
        self.summary_label.configure(
            text="Selecionado: %s%s  (~%d animações)." %
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
            self.messagebox.showerror(APP_TITLE, "OLGame.upk não encontrado nesta pasta.")
            return
        mode = self.mode_var.get()
        breathing = bool(self.breathing_var.get())
        total = self.summary_label.cget("text")
        answer = self.messagebox.askyesno(
            APP_TITLE,
            "Aplicar as alterações?\n\n%s\n\nO backup do OLGame.upk original será "
            "criado (se ainda não existir). Feche o jogo antes de continuar." % total,
        )
        if not answer:
            return
        self._set_busy(True)
        self.log("")
        self.log("=== Aplicando patch ===")
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
                APP_TITLE, "Não existe backup (OLGame.upk.backup) para restaurar."
            )
            return
        answer = self.messagebox.askyesno(
            APP_TITLE,
            "Restaurar o OLGame.upk original?\n\nO backup será renomeado para "
            "OLGame.upk, substituindo o arquivo modificado. Feche o jogo antes.",
        )
        if not answer:
            return
        self._set_busy(True)
        self.log("")
        self.log("=== Restaurando arquivo original ===")
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
            self.messagebox.showinfo(APP_TITLE, "Aguarde a operação terminar.")
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
                    self.log("Concluído.")
                    self.messagebox.showinfo(
                        APP_TITLE,
                        "Patch aplicado com sucesso!\n\nAbra o jogo e teste. "
                        "Para voltar ao original use 'Restaurar arquivo original'.",
                    )
                    self.refresh_status()
                elif kind == "restore_done":
                    self.log("Restauracao concluida.")
                    self.messagebox.showinfo(
                        APP_TITLE,
                        "OLGame.upk original restaurado com sucesso.",
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
            print("Animações do herói : %d" % stats["tracks"])
            print("Com balanço        : %d" % stats["varying"])
            return 0

        if not args.mode:
            print("ERRO: informe --mode (%s) ou use --analyze/--restore." %
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
        print("Patch gravado em: %s (%d bytes)" % (output, len(patched)))
        for key, value in report.items():
            print("  %-32s %s" % (key, value))
        return 0
    except PatchError as exc:
        print("ERRO: %s" % exc, file=sys.stderr)
        return 1


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(
        description="Remove o head bob do Outlast editando OLGame.upk.",
    )
    parser.add_argument("--cli", action="store_true", help="usa a linha de comando")
    parser.add_argument("--package", help="caminho do OLGame.upk")
    parser.add_argument("--mode", choices=MODE_ORDER, help="modo de remoção")
    parser.add_argument("--breathing", action="store_true",
                        help="remove também o balanço de respiração (idle)")
    parser.add_argument("--output", help="grava o patch em outro arquivo (não mexe no original)")
    parser.add_argument("--apply", action="store_true",
                        help="aplica no OLGame.upk (cria backup automaticamente)")
    parser.add_argument("--restore", action="store_true", help="restaura o backup")
    parser.add_argument("--analyze", action="store_true", help="mostra estatisticas do pacote")
    args = parser.parse_args(argv)

    if args.cli or args.mode or args.apply or args.restore or args.analyze:
        return run_cli(args)

    try:
        import tkinter as tk
    except ImportError:
        print("tkinter não está disponível. Use o modo --cli.", file=sys.stderr)
        return 1

    root = tk.Tk()
    PatcherGUI(root, args.package or _default_package_path())
    root.mainloop()
    return 0


if __name__ == "__main__":
    sys.exit(main())
