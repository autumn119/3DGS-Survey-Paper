#!/usr/bin/env python3
"""
preprocess/prepare_images.py
Screen UAV images for blur, then resize to 1920×1080.

Usage:
    python prepare_images.py --scene chaoli
    python prepare_images.py --scene all
"""

import argparse, shutil
from pathlib import Path
import cv2
import numpy as np
from tqdm import tqdm

SCENES   = ["chaoli", "zeli", "chongjiang", "zengchong"]
OUT_W, OUT_H = 1920, 1080
BLUR_THRESH  = 80.0   # Laplacian variance below this → blurry


def laplacian_var(gray: np.ndarray) -> float:
    return cv2.Laplacian(gray, cv2.CV_64F).var()


def process_scene(scene: str, data_root: Path) -> None:
    src = data_root / scene / "images_raw"
    dst = data_root / scene / "images"
    if not src.exists():
        print(f"[{scene}] images_raw/ not found, skipping.")
        return
    dst.mkdir(parents=True, exist_ok=True)

    exts   = {".jpg", ".jpeg", ".png", ".JPG", ".JPEG", ".PNG"}
    imgs   = [p for p in sorted(src.iterdir()) if p.suffix in exts]
    kept, dropped = 0, 0

    for p in tqdm(imgs, desc=f"{scene}", unit="img"):
        img  = cv2.imread(str(p))
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        if laplacian_var(gray) < BLUR_THRESH:
            dropped += 1
            continue
        resized = cv2.resize(img, (OUT_W, OUT_H), interpolation=cv2.INTER_LANCZOS4)
        cv2.imwrite(str(dst / p.name), resized,
                    [cv2.IMWRITE_JPEG_QUALITY, 95])
        kept += 1

    print(f"[{scene}] kept {kept}, dropped {dropped} blurry images → {dst}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--scene", default="all",
                    help="Scene name or 'all'")
    ap.add_argument("--data", default="../../data",
                    help="Path to data/ directory")
    ap.add_argument("--blur_thresh", type=float, default=BLUR_THRESH)
    args = ap.parse_args()

    global BLUR_THRESH
    BLUR_THRESH = args.blur_thresh
    data_root   = Path(args.data).resolve()
    targets     = SCENES if args.scene == "all" else [args.scene]
    for s in targets:
        process_scene(s, data_root)


if __name__ == "__main__":
    main()
