#!/usr/bin/env bash
# methods/nerf/train.sh — NeRF (bmild/nerf-pytorch style)
# Repo on server: /root/autodl-tmp/autodl-envs/nerf  (run_nerf.py)
#
# Usage:  bash train.sh <scene|all>
# Input:  datasets/guloushuju/<scene>/nerf  (transforms_*.json, blender format)
# Output: output/<scene>/nerf
#
# Real config used on server (see output/*/nerf/nerf_train/args.txt):
#   dataset_type=blender, factor=8, N_rand=1024, N_samples=64,
#   N_importance=128, multires=10, lrate=5e-4, lrate_decay=250, llffhold=8
set -euo pipefail
source "$(dirname "$0")/../../scenes.sh"

train_scene() {
    local KEY="$1"
    local SRC; SRC="$(scene_dir "$KEY")/nerf"
    local OUT="${OUTPUT_ROOT}/${CN_NAME[$KEY]:-$KEY}/nerf"
    echo "===== NeRF  [${KEY}] ====="
    [ -d "$SRC" ] || { echo "ERROR: ${SRC} not found"; return 1; }
    mkdir -p "$OUT"

    python "${NERF_ROOT}/run_nerf.py" \
        --datadir "$SRC" --basedir "$OUT" --expname nerf_train \
        --dataset_type blender --factor 8 \
        --N_rand 1024 --N_samples 64 --N_importance 128 \
        --multires 10 --multires_views 4 \
        --lrate 5e-4 --lrate_decay 250 --llffhold 8 \
        --i_testset 50000 --i_weights 10000
    echo "[${KEY}] NeRF done → ${OUT}"
}

T="${1:-all}"
if [ "$T" = all ]; then for s in "${SCENES[@]}"; do train_scene "$s"; done
else train_scene "$T"; fi
