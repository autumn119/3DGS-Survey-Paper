#!/usr/bin/env bash
# methods/2dgs/train.sh — 2D Gaussian Splatting
# Repo: hbb1/2d-gaussian-splatting  (server: /root/autodl-tmp/2d-gaussian-splatting)
#
# Usage:  bash train.sh <scene|all>
# Input:  datasets/guloushuju/<scene>/2dgs   (COLMAP sparse + images/)
# Output: output/<scene>/2dgs
set -euo pipefail
source "$(dirname "$0")/../../scenes.sh"

ITERS=30000

train_scene() {
    local KEY="$1"
    local SRC; SRC="$(scene_dir "$KEY")/2dgs"
    local OUT="${OUTPUT_ROOT}/${CN_NAME[$KEY]:-$KEY}/2dgs"
    echo "===== 2DGS  [${KEY}] ====="
    [ -d "$SRC" ] || { echo "ERROR: ${SRC} not found"; return 1; }
    mkdir -p "$OUT"

    # sh_degree=3, full resolution (-1), then render + metrics on test split
    python "${GS2D_ROOT}/train.py" \
        -s "$SRC" -m "$OUT" \
        --iterations "$ITERS" --resolution -1 --sh_degree 3 --eval
    python "${GS2D_ROOT}/render.py" -m "$OUT" --skip_train
    python "${GS2D_ROOT}/metrics.py" -m "$OUT"
    echo "[${KEY}] 2DGS done → ${OUT}"
}

T="${1:-all}"
if [ "$T" = all ]; then for s in "${SCENES[@]}"; do train_scene "$s"; done
else train_scene "$T"; fi
