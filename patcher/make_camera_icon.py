#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Gera camera_icon.ico (multi-tamanho) para o Outlast Head Bob Patcher.

Desenha uma camera em alta resolucao com supersampling (antialiasing),
codifica cada tamanho como PNG dentro de um container ICO usando apenas a
biblioteca padrao do Python (sem Pillow).

Tamanhos incluidos: 256, 128, 64, 48, 32, 16 (Windows usa o mais adequado
para o arquivo .exe e para a barra de titulo da janela).

Execucao:
    py -3 make_camera_icon.py
    python make_camera_icon.py
"""
from __future__ import annotations

import os
import struct
import zlib

# ---------------------------------------------------------------- cores (RGBA)
BODY = (50, 50, 52, 255)          # corpo da camera (cinza escuro)
BODY_DARK = (38, 38, 40, 255)     # faixa inferior do corpo
LENS_OUTER = (18, 18, 20, 255)    # aro externo da lente
LENS_MID = (30, 30, 34, 255)      # aro medio da lente
LENS_INNER = (10, 10, 12, 255)    # vidro da lente
LENS_HIGHLIGHT = (255, 255, 255, 40)  # brilho na lente
FLASH = (255, 249, 196, 235)      # flash (amarelo claro)
FLASH_CORE = (255, 235, 59, 255)  # nucleo do flash
BUTTON = (70, 70, 74, 255)        # botoes pequenos no corpo
TRANSPARENT = (0, 0, 0, 0)

SRC = 2048   # resolucao de desenho (supersampling)
OUT = 512    # resolucao final da imagem master
SCALE = SRC // OUT


def new_buffer(w: int, h: int) -> bytearray:
    return bytearray(w * h * 4)


def set_pixel(buf: bytearray, w: int, h: int, x: int, y: int, rgba) -> None:
    if 0 <= x < w and 0 <= y < h:
        i = (y * w + x) * 4
        buf[i] = rgba[0]
        buf[i + 1] = rgba[1]
        buf[i + 2] = rgba[2]
        buf[i + 3] = rgba[3]


def fill_rect(buf, w, h, x0, y0, x1, y1, rgba) -> None:
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            set_pixel(buf, w, h, x, y, rgba)


def fill_circle(buf, w, h, cx, cy, r, rgba) -> None:
    r2 = r * r
    for y in range(max(0, cy - r), min(h - 1, cy + r) + 1):
        dy = y - cy
        dy2 = dy * dy
        for x in range(max(0, cx - r), min(w - 1, cx + r) + 1):
            dx = x - cx
            if dx * dx + dy2 <= r2:
                set_pixel(buf, w, h, x, y, rgba)


def fill_rounded_rect(buf, w, h, x0, y0, x1, y1, rad, rgba) -> None:
    cx0, cy0 = x0 + rad, y0 + rad
    cx1, cy1 = x1 - rad, y1 - rad
    r2 = rad * rad
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            outside = False
            if x <= cx0 and y <= cy0:
                outside = (x - cx0) ** 2 + (y - cy0) ** 2 > r2
            elif x >= cx1 and y <= cy0:
                outside = (x - cx1) ** 2 + (y - cy0) ** 2 > r2
            elif x <= cx0 and y >= cy1:
                outside = (x - cx0) ** 2 + (y - cy1) ** 2 > r2
            elif x >= cx1 and y >= cy1:
                outside = (x - cx1) ** 2 + (y - cy1) ** 2 > r2
            if not outside:
                set_pixel(buf, w, h, x, y, rgba)


def downsample(src: bytearray, sw: int, sh: int) -> bytearray:
    dw, dh = sw // SCALE, sh // SCALE
    dst = bytearray(dw * dh * 4)
    for oy in range(dh):
        sy0 = oy * SCALE
        for ox in range(dw):
            sx0 = ox * SCALE
            r = g = b = a = 0
            for yy in range(sy0, sy0 + SCALE):
                base = (yy * sw + sx0) * 4
                for xx in range(sx0, sx0 + SCALE):
                    i = base + (xx - sx0) * 4
                    r += src[i]
                    g += src[i + 1]
                    b += src[i + 2]
                    a += src[i + 3]
            n = SCALE * SCALE
            ai = a // n
            if ai:
                r = min(255, r * 255 // ai)
                g = min(255, g * 255 // ai)
                b = min(255, b * 255 // ai)
            j = (oy * dw + ox) * 4
            dst[j] = r // n
            dst[j + 1] = g // n
            dst[j + 2] = b // n
            dst[j + 3] = ai
    return dst


def png_encode(rgba: bytearray, w: int, h: int) -> bytes:
    def chunk(ctype: bytes, data: bytes) -> bytes:
        crc = zlib.crc32(ctype + data) & 0xFFFFFFFF
        return struct.pack(">I", len(data)) + ctype + data + struct.pack(">I", crc)

    raw = bytearray()
    stride = w * 4
    for y in range(h):
        raw.append(0)
        raw.extend(rgba[y * stride:(y + 1) * stride])
    idat = zlib.compress(bytes(raw), 6)

    png = bytearray()
    png += b"\x89PNG\r\n\x1a\n"
    ihdr = struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)
    png += chunk(b"IHDR", ihdr)
    png += chunk(b"IDAT", idat)
    png += chunk(b"IEND", b"")
    return bytes(png)


def draw_camera(w: int, h: int) -> bytearray:
    buf = new_buffer(w, h)

    # corpo da camera (arredondado)
    fill_rounded_rect(buf, w, h, 85 * SCALE, 150 * SCALE, 427 * SCALE, 370 * SCALE, 60 * SCALE, BODY)
    # faixa inferior um pouco mais escura
    fill_rect(buf, w, h, 85 * SCALE, 300 * SCALE, 427 * SCALE, 370 * SCALE, BODY_DARK)

    # lente (concentrica)
    lcx, lcy = 256 * SCALE, 262 * SCALE
    fill_circle(buf, w, h, lcx, lcy, 100 * SCALE, LENS_OUTER)
    fill_circle(buf, w, h, lcx, lcy, 78 * SCALE, LENS_MID)
    fill_circle(buf, w, h, lcx, lcy, 56 * SCALE, LENS_INNER)
    # brilho na lente
    fill_circle(buf, w, h, 218 * SCALE, 226 * SCALE, 16 * SCALE, LENS_HIGHLIGHT)

    # flash (topo direito do corpo)
    fill_circle(buf, w, h, 368 * SCALE, 190 * SCALE, 19 * SCALE, FLASH)
    fill_circle(buf, w, h, 368 * SCALE, 190 * SCALE, 11 * SCALE, FLASH_CORE)

    # botoes pequenos na frente
    fill_circle(buf, w, h, 150 * SCALE, 330 * SCALE, 12 * SCALE, BUTTON)
    fill_circle(buf, w, h, 362 * SCALE, 330 * SCALE, 12 * SCALE, BUTTON)

    return buf  # alta resolucao (2048x2048); redimensionado depois em resize_to


def ico_entry(w: int, h: int, png_data: bytes, offset: int) -> bytes:
    bw = 0 if w >= 256 else w
    bh = 0 if h >= 256 else h
    return struct.pack(
        "<BBBBHHII",
        bw, bh,
        0,
        0,
        1,
        32,
        len(png_data),
        offset,
    )


def build_ico(images: list) -> bytes:
    count = len(images)
    header = struct.pack("<HHH", 0, 1, count)
    entries = bytearray()
    data = bytearray()
    offset = 6 + 16 * count
    for w, h, png in images:
        entries += ico_entry(w, h, png, offset)
        data += png
        offset += len(png)
    return header + bytes(entries) + bytes(data)


def resize_to(master: bytearray, src: int, size: int) -> bytearray:
    factor = src // size
    small = bytearray(size * size * 4)
    for oy in range(size):
        sy0 = oy * factor
        for ox in range(size):
            sx0 = ox * factor
            r = g = b = a = 0
            for yy in range(sy0, sy0 + factor):
                base = (yy * src + sx0) * 4
                for xx in range(sx0, sx0 + factor):
                    i = base + (xx - sx0) * 4
                    r += master[i]
                    g += master[i + 1]
                    b += master[i + 2]
                    a += master[i + 3]
            n = factor * factor
            ai = a // n
            if ai:
                r = min(255, r * 255 // ai)
                g = min(255, g * 255 // ai)
                b = min(255, b * 255 // ai)
            j = (oy * size + ox) * 4
            small[j] = r // n
            small[j + 1] = g // n
            small[j + 2] = b // n
            small[j + 3] = ai
    return small


def main() -> None:
    here = os.path.dirname(os.path.abspath(__file__))
    master = draw_camera(SRC, SRC)

    sizes = [256, 128, 64, 48, 32, 16]
    images = []
    for size in sizes:
        small = resize_to(master, SRC, size)
        images.append((size, size, png_encode(small, size, size)))

    ico = build_ico(images)
    out_path = os.path.join(here, "camera_icon.ico")
    with open(out_path, "wb") as f:
        f.write(ico)
    print(f"Gerado: {out_path} ({len(ico)} bytes, {len(images)} tamanhos: {sizes})")


if __name__ == "__main__":
    main()
