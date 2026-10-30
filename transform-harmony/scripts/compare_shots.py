#!/usr/bin/env python3
"""对比 Android 真值图与鸿蒙截图。差异像素占比 > 阈值则 FAIL（默认 1%）。
用法: compare_shots.py <android.png> <harmony.png> [--threshold 0.01] [--out report.json]
依赖: Pillow（无则仅报尺寸不一致并 exit 2）
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("android")
    ap.add_argument("harmony")
    ap.add_argument("--threshold", type=float, default=0.01)
    ap.add_argument("--out", default="")
    args = ap.parse_args()
    a_path, h_path = Path(args.android), Path(args.harmony)
    if not a_path.is_file() or not h_path.is_file():
        print("缺文件", file=sys.stderr)
        return 2
    try:
        from PIL import Image, ImageChops
    except ImportError:
        print("需要 Pillow: pip install Pillow", file=sys.stderr)
        return 2

    a = Image.open(a_path).convert("RGB")
    h = Image.open(h_path).convert("RGB")
    if a.size != h.size:
        # 缩放到 Android 尺寸再比（标注 scale）
        h = h.resize(a.size, Image.Resampling.LANCZOS)
        scaled = True
    else:
        scaled = False
    diff = ImageChops.difference(a, h)
    # 任通道差 > 8 计为差异像素（抗压缩噪）
    pixels = list(diff.getdata())
    total = len(pixels)
    changed = sum(1 for r, g, b in pixels if r > 8 or g > 8 or b > 8)
    ratio = changed / total if total else 1.0
    report = {
        "android": str(a_path),
        "harmony": str(h_path),
        "size": list(a.size),
        "scaled_harmony": scaled,
        "diff_ratio": round(ratio, 6),
        "threshold": args.threshold,
        "pass": ratio <= args.threshold,
        "action": "ok" if ratio <= args.threshold else "sync_optimize",
    }
    line = (
        f"{'PASS' if report['pass'] else 'FAIL'} diff={ratio*100:.2f}% "
        f"threshold={args.threshold*100:.2f}% → {report['action']}"
    )
    print(line)
    if args.out:
        Path(args.out).write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    return 0 if report["pass"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
