#!/usr/bin/env python3
"""
preprocess/extract_frames.py
Extract frames from a UAV video into frame_XXXXXX.jpg, with optional blur
screening. This is how the Drum Tower image corpora were produced
(frame_000000.jpg … per scene).

Usage:
    python extract_frames.py --video celi.mp4 --out ../../data/则里/images
    python extract_frames.py --video celi.mp4 --out out/ --every 3 --min_sharp 60
"""

import argparse
from pathlib import Path
import cv2


def sharp(gray):
    return cv2.Laplacian(gray, cv2.CV_64F).var()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--video", required=True, help="Input UAV video")
    ap.add_argument("--out",   required=True, help="Output images/ dir")
    ap.add_argument("--every", type=int, default=1,
                    help="Keep 1 frame every N frames")
    ap.add_argument("--min_sharp", type=float, default=0.0,
                    help="Drop frames with Laplacian variance below this")
    ap.add_argument("--resize", default=None,
                    help="Optional WxH, e.g. 1920x1080")
    args = ap.parse_args()

    out = Path(args.out); out.mkdir(parents=True, exist_ok=True)
    size = None
    if args.resize:
        w, h = map(int, args.resize.lower().split("x"))
        size = (w, h)

    cap = cv2.VideoCapture(args.video)
    idx, saved = 0, 0
    while True:
        ok, frame = cap.read()
        if not ok:
            break
        if idx % args.every == 0:
            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            if sharp(gray) >= args.min_sharp:
                if size:
                    frame = cv2.resize(frame, size, interpolation=cv2.INTER_LANCZOS4)
                cv2.imwrite(str(out / f"frame_{saved:06d}.jpg"), frame,
                            [cv2.IMWRITE_JPEG_QUALITY, 95])
                saved += 1
        idx += 1
    cap.release()
    print(f"Read {idx} frames, saved {saved} → {out}")


if __name__ == "__main__":
    main()
