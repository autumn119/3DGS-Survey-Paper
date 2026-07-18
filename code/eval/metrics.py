#!/usr/bin/env python3
"""
eval/metrics.py
Compute PSNR / SSIM / LPIPS + training time for rendered test views.

Usage:
    python metrics.py --scene chaoli --method 3dgs
    python metrics.py --scene all   --method all
"""

import argparse, time, json
from pathlib import Path
import numpy as np
import cv2
from skimage.metrics import peak_signal_noise_ratio as psnr
from skimage.metrics import structural_similarity  as ssim
import lpips
import torch
import pandas as pd
from tabulate import tabulate

SCENES  = ["chaoli", "zeli", "chongjiang", "zengchong"]
METHODS = ["nerf", "2dgs", "3dgs", "ingp"]
DATA_ROOT = Path(__file__).parent.parent.parent / "data"

loss_fn = lpips.LPIPS(net="alex")


def img_to_tensor(img_bgr: np.ndarray) -> torch.Tensor:
    rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB).astype(np.float32) / 127.5 - 1
    return torch.tensor(rgb).permute(2, 0, 1).unsqueeze(0)


def eval_pair(ref: np.ndarray, pred: np.ndarray) -> dict:
    ref_g  = cv2.cvtColor(ref,  cv2.COLOR_BGR2GRAY)
    pred_g = cv2.cvtColor(pred, cv2.COLOR_BGR2GRAY)
    p  = psnr(ref, pred, data_range=255)
    s  = ssim(ref_g, pred_g, data_range=255)
    lp = loss_fn(img_to_tensor(ref), img_to_tensor(pred)).item()
    return {"PSNR": round(p, 4), "SSIM": round(s, 4), "LPIPS": round(lp, 4)}


def eval_scene_method(scene: str, method: str) -> dict | None:
    ref_dir  = DATA_ROOT / scene / "dense" / "images"
    pred_dir = DATA_ROOT / scene / "output" / method / "test_renders"
    split    = DATA_ROOT / "splits" / f"{scene}_test.txt"

    for d in (ref_dir, pred_dir, split):
        if not d.exists():
            print(f"  [skip] missing {d}"); return None

    test_imgs = split.read_text().splitlines()
    results   = []
    for name in test_imgs:
        ref  = cv2.imread(str(ref_dir  / name))
        pred = cv2.imread(str(pred_dir / name))
        if ref is None or pred is None: continue
        if ref.shape != pred.shape:
            pred = cv2.resize(pred, (ref.shape[1], ref.shape[0]))
        results.append(eval_pair(ref, pred))

    if not results: return None
    avg = {k: round(np.mean([r[k] for r in results]), 4) for k in results[0]}
    avg.update({"scene": scene, "method": method, "n_views": len(results)})
    return avg


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--scene",  default="all")
    ap.add_argument("--method", default="all")
    ap.add_argument("--data",   default=None)
    args = ap.parse_args()

    global DATA_ROOT
    if args.data: DATA_ROOT = Path(args.data).resolve()
    scenes  = SCENES  if args.scene  == "all" else [args.scene]
    methods = METHODS if args.method == "all" else [args.method]

    rows = []
    for sc in scenes:
        for mt in methods:
            print(f"Evaluating {sc}/{mt} …")
            r = eval_scene_method(sc, mt)
            if r: rows.append(r)

    if not rows:
        print("No results found."); return

    df = pd.DataFrame(rows)[["scene","method","PSNR","SSIM","LPIPS","n_views"]]
    print("\n" + tabulate(df, headers="keys", tablefmt="github", index=False))

    out = DATA_ROOT / "results_summary.csv"
    df.to_csv(out, index=False)
    print(f"\nSaved → {out}")


if __name__ == "__main__":
    main()
