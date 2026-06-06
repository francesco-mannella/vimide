#!/usr/bin/env python3
"""Post-process demo gif: add semi-transparent keyboard shortcut badges."""

import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

REPO = Path(__file__).parent.parent
CAST = Path(__file__).parent / "vimdemo.cast"
GIF_IN = REPO / "docs" / "demo.gif"
GIF_OUT = REPO / "docs" / "demo.gif"

FONT_BOLD = "/usr/share/fonts/truetype/liberation/LiberationMono-Bold.ttf"
FONT_REG  = "/usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf"

# (start_eff_s, end_eff_s, shortcut, description, hex_color)
ANNOTATIONS = [
    ( 5.0,  9.5, ",cp",   "open Python IDE",     "#ff9944"),
    ( 9.5, 13.5, "C-f",   "auto-format (black)", "#44aaff"),
    (13.5, 14.6, ":w",    "save",                "#44ff88"),
    (14.6, 17.7, "C-w h", "object explorer",     "#ffcc44"),
    (17.7, 19.1, "C-w l", "back to editor",      "#aaaaaa"),
    (19.1, 22.1, "C-w l", "file explorer",       "#ffcc44"),
    (22.1, 23.7, "C-w h", "back to editor",      "#aaaaaa"),
    (23.7, 27.5, r"\as",  "open IPython",        "#cc88ff"),
    (27.5, 36.0, r"\rr",  "run script",          "#ff5555"),
]


def effective_times(cast_path, idle_limit=3.0):
    times = []
    prev_raw = prev_eff = 0.0
    with open(cast_path) as f:
        f.readline()
        for line in f:
            ev = json.loads(line)
            if ev[1] == "o":
                prev_eff += min(ev[0] - prev_raw, idle_limit)
                times.append(prev_eff)
                prev_raw = ev[0]
    return times


def annotation_at(eff_t):
    for start, end, key, desc, col in ANNOTATIONS:
        if start <= eff_t < end:
            return key, desc, col
    return None, None, None


def hex_to_rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))


def draw_badge(frame_rgb, key, desc, color_hex):
    img = frame_rgb.convert("RGBA")
    W, H = img.size
    rgb = hex_to_rgb(color_hex)

    fk = ImageFont.truetype(FONT_BOLD, 24)
    fd = ImageFont.truetype(FONT_REG,  19)

    tmp = ImageDraw.Draw(Image.new("RGBA", (1, 1)))
    kw = tmp.textlength(key,  font=fk)
    dw = tmp.textlength(desc, font=fd)

    pad_x, pad_y = 16, 10
    bar = 5
    box_w = int(max(kw, dw)) + bar + pad_x * 2
    box_h = 24 + 19 + pad_y * 3

    # bottom-right, above tmux status bar (~28px)
    margin = 14
    tmux_h = 28
    x0 = W - box_w - margin
    y0 = H - box_h - tmux_h - margin
    x1, y1 = x0 + box_w, y0 + box_h

    overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)

    # background box
    d.rounded_rectangle([x0, y0, x1, y1], radius=7, fill=(15, 15, 15, 210))
    # colored left accent bar
    d.rectangle([x0, y0, x0 + bar, y1], fill=(*rgb, 230))

    img = Image.alpha_composite(img, overlay)
    d2 = ImageDraw.Draw(img)
    tx = x0 + bar + pad_x
    d2.text((tx, y0 + pad_y),          key,  font=fk, fill=(*rgb, 255))
    d2.text((tx, y0 + pad_y + 24 + 6), desc, font=fd, fill=(210, 210, 210, 230))

    return img.convert("RGB")


def main():
    eff = effective_times(CAST)
    total_eff = eff[-1] if eff else 1.0

    gif = Image.open(GIF_IN)
    n = gif.n_frames
    frames, durations = [], []

    for i in range(n):
        gif.seek(i)
        dur = gif.info.get("duration", 100)
        eff_t = i * total_eff / max(n - 1, 1)
        key, desc, col = annotation_at(eff_t)
        f = gif.copy().convert("RGB")
        if key:
            f = draw_badge(f, key, desc, col)
        frames.append(f)
        durations.append(dur)

    frames[0].save(
        GIF_OUT,
        save_all=True,
        append_images=frames[1:],
        loop=0,
        duration=durations,
        optimize=False,
    )
    print(f"written: {GIF_OUT}  ({n} frames)")


if __name__ == "__main__":
    main()
