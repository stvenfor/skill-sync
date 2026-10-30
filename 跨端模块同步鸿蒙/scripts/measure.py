#!/usr/bin/env python3
"""uiautomator dump -> dp 测量表（markdown）。用法: measure.py <ui.xml> <dpi> [页面名]"""
import os
import re
import sys
import xml.etree.ElementTree as ET


def bounds(node):
    found = re.findall(r'\d+', node.get('bounds', ''))
    if len(found) != 4:
        return None
    return [int(v) for v in found]


def main():
    path = sys.argv[1]
    dpi = float(sys.argv[2]) if len(sys.argv) > 2 else 440.0
    title = sys.argv[3] if len(sys.argv) > 3 else os.path.basename(path)
    scale = dpi / 160.0

    root = ET.parse(path).getroot()
    nodes = list(root.iter('node'))
    screen_w = max((bounds(n)[2] for n in nodes if bounds(n)), default=0) / scale
    screen_h = max((bounds(n)[3] for n in nodes if bounds(n)), default=0) / scale

    print(f"# {title} 测量表（单位 dp，1dp≈1vp；屏幕 {screen_w:.1f} x {screen_h:.1f}）\n")
    print("| 层级 | class | resource-id | x | y | w | h | 距父 l/t/r/b | 文案 |")
    print("|---|---|---|---|---|---|---|---|---|")

    def walk(node, depth, parent):
        b = bounds(node)
        rid = node.get('resource-id', '').split(':id/')[-1]
        text = (node.get('text') or node.get('content-desc') or '').strip()
        cls = node.get('class', '').split('.')[-1]
        keep = b and (rid or text or node.get('clickable') == 'true' or node.get('scrollable') == 'true')
        if keep:
            x1, y1, x2, y2 = [v / scale for v in b]
            w, h = x2 - x1, y2 - y1
            if w >= 1 and h >= 1:
                if parent and bounds(parent):
                    px1, py1, px2, py2 = [v / scale for v in bounds(parent)]
                    ml, mt = x1 - px1, y1 - py1
                    mr, mb = px2 - x2, py2 - y2
                    pad = f"{ml:.0f}/{mt:.0f}/{mr:.0f}/{mb:.0f}"
                else:
                    pad = "-"
                safe = text.replace('|', '\\|')[:40]
                print(
                    f"| {depth} | {cls} | {rid or '-'} | {x1:.0f} | {y1:.0f} | {w:.0f} | {h:.0f} | {pad} | {safe} |"
                )
        for child in list(node):
            walk(child, depth + 1, node if keep else parent)

    walk(root, 0, None)


if __name__ == '__main__':
    main()
