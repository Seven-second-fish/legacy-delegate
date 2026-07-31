#!/usr/bin/env python3
"""Generate docs/demo-bare-vs-skill.gif from docs/demo-bare-vs-skill.png (三栏静图裁切轮播).

若需从零重绘中文幕：准备 CJK 字体到 docs/.fonts/NotoSansCJKsc-Regular.otf 后改用 --render。
默认：--from-png（不依赖本机 CJK 字体）。
"""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
PNG = DOCS / "demo-bare-vs-skill.png"
GIF = DOCS / "demo-bare-vs-skill.gif"


def gif_from_png(png_path: Path = PNG, gif_path: Path = GIF) -> None:
    png = Image.open(png_path).convert("RGB")
    w, h = png.size
    m = int(w * 0.02)
    panel_w = (w - 2 * m) // 3
    frames = []
    for i in range(3):
        left = m + i * panel_w
        crop = png.crop((left, int(h * 0.08), left + panel_w, int(h * 0.92)))
        canvas = Image.new("RGB", (560, 420), (18, 22, 28))
        c = crop.copy()
        c.thumbnail((540, 400))
        canvas.paste(c, ((560 - c.width) // 2, (420 - c.height) // 2))
        frames.append(canvas)
    frames[0].save(
        gif_path,
        save_all=True,
        append_images=frames[1:],
        duration=2800,
        loop=0,
        optimize=False,
    )
    print(f"Wrote {gif_path} ({len(frames)} frames) from {png_path}")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--from-png", action="store_true", default=True)
    args = ap.parse_args()
    if not PNG.exists():
        raise SystemExit(f"Missing {PNG}; place a three-panel PNG first")
    gif_from_png()


if __name__ == "__main__":
    main()
