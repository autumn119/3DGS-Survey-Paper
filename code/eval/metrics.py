#!/usr/bin/env python3
"""
eval/metrics.py
Compute PSNR / SSIM / LPIPS on rendered test views for each scene & method.

Matches the on-server output layout:
    output/<cn_scene>/2dgs/test/ours_30000/{renders,gt}/*.png
    output/<cn_scene>/3dgs/test/ours_30000/{renders,gt}/*.png
    output/<cn_scene>/ingp/test_renders/*  (+ gt from dataset)
    output/<cn_scene>/nerf/nerf_train/testset_*/*.png

Usage:
    python metrics.py --scene all --method all
    python metrics.py --scene celi --method 2dgs
"""

import argparse, glob, os
from pathlib import Path
import numpy as np
import cv2
from skimage.metrics import peak_signal_noise_ratio as psnr
from skimage.metrics import structural_similarity  as ssim
import lpips, torch
import pandas as pd
from tabulate import tabulate

# pinyin key -> chinese on-disk dir
CN = {"celi": "则里", "zhaoli": "朝利",
      "congjiang": "从江", "zhengchong": "增冲"}
SCENES  = list(CN)
METHODS = ["nerf", "2dgs", "3dgs", "ingp"]
OUTPUT_ROOT = Path("/root/autodl-tmp/output")

loss_fn = lpips.LPIPS(net="alex")


def to_tensor(bgr):
    rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB).astype(np.float32) / 127.5 - 1
    return torch.tensor(rgb).permute(2, 0, 1).unsqueeze(0)


def score(ref, pred):
    if ref.shape != pred.shape:
        pred = cv2.resize(pred, (ref.shape[1], ref.shape[0]))
    g1 = cv2.cvtColor(ref,  cv2.COLOR_BGR2GRAY)
    g2 = cv2.cvtColor(pred, cv2.COLOR_BGR2GRAY)
    return (psnr(ref, pred, data_range=255),
            ssim(g1, g2, data_range=255),
            loss_fn(to_tensor(ref), to_tensor(pred)).item())


def find_pairs(scene, method):
    """Return list of (gt_path, render_path) for a scene/method."""
    cn   = CN[scene]
    base = OUTPUT_ROOT / cn / method
    # Gaussian-splatting layout: test/ours_*/renders + gt
    for testdir in sorted(base.glob("test/ours_*")):
        r = sorted((testdir / "renders").glob("*"))
        g = sorted((testdir / "gt").glob("*"))
        if r and g and len(r) == len(g):
            return list(zip(g, r))
    # INGP layout: test_renders + dataset test images as gt
    tr = base / "test_renders"
    if tr.exists():
        renders = sorted(tr.glob("*.png")) + sorted(tr.glob("*.jpg"))
        gt_dir  = Path("/root/autodl-tmp/datasets/guloushuju")/cn/"ingp"/"test"
        gts = sorted(gt_dir.glob("*"))
        if renders and gts:
            n = min(len(renders), len(gts))
            return list(zip(gts[:n], renders[:n]))
    return []


def eval_one(scene, method):
    pairs = find_pairs(scene, method)
    if not pairs:
        print(f"  [skip] {scene}/{method}: no render/gt pairs found")
        return None
    ps, ss, lp = [], [], []
    for gt_p, rd_p in pairs:
        ref, pred = cv2.imread(str(gt_p)), cv2.imread(str(rd_p))
        if ref is None or pred is None:
            continue
        p, s, l = score(ref, pred)
        ps.append(p); ss.append(s); lp.append(l)
    if not ps:
        return None
    return {"scene": scene, "method": method,
            "PSNR": round(float(np.mean(ps)), 3),
            "SSIM": round(float(np.mean(ss)), 4),
            "LPIPS": round(float(np.mean(lp)), 4),
            "n_views": len(ps)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--scene",  default="all")
    ap.add_argument("--method", default="all")
    ap.add_argument("--output_root", default=None)
    args = ap.parse_args()

    global OUTPUT_ROOT
    if args.output_root:
        OUTPUT_ROOT = Path(args.output_root)
    scenes  = SCENES  if args.scene  == "all" else [args.scene]
    methods = METHODS if args.method == "all" else [args.method]

    rows = []
    for sc in scenes:
        for mt in methods:
            print(f"Evaluating {sc}/{mt} …")
            r = eval_one(sc, mt)
            if r:
                rows.append(r)
    if not rows:
        print("No results found."); return

    df = pd.DataFrame(rows)[["scene", "method", "PSNR", "SSIM", "LPIPS", "n_views"]]
    print("\n" + tabulate(df, headers="keys", tablefmt="github", index=False))
    out = OUTPUT_ROOT / "results_summary.csv"
    df.to_csv(out, index=False)
    print(f"\nSaved → {out}")


if __name__ == "__main__":
    main()
