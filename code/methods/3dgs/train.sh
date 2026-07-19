#!/usr/bin/env bash
# methods/3dgs/train.sh — 3D Gaussian Splatting
# Repo: graphdeco-inria/gaussian-splatting
#   clone to $GS3D_ROOT (default /root/autodl-tmp/gaussian-splatting)
#
# NOTE: 3DGS was NOT yet run on the training server at the time this repo
#       was assembled. This script reproduces it using the SAME COLMAP
#       inputs already prepared for 2DGS (shared sparse reconstruction).
#
# Usage:  bash train.sh <scene|all>
# Input:  datasets/guloushuju/<scene>/2dgs   (reuses 2DGS COLMAP workspace)
# Output: output/<scene>/3dgs
set -euo pipefail
source "$(dirname "$0")/../../scenes.sh"

ITERS=30000

train_scene() {
    local KEY="$1"
    local SRC; SRC="$(scene_dir "$KEY")/2dgs"    # same COLMAP inputs as 2DGS
    local OUT="${OUTPUT_ROOT}/${CN_NAME[$KEY]:-$KEY}/3dgs"
    echo "===== 3DGS  [${KEY}] ====="
    [ -d "$GS3D_ROOT" ] || { echo "ERROR: clone gaussian-splatting to ${GS3D_ROOT}"; return 1; }
    [ -d "$SRC" ] || { echo "ERROR: ${SRC} not found"; return 1; }
    mkdir -p "$OUT"

    python "${GS3D_ROOT}/train.py" \
        -s "$SRC" -m "$OUT" \
        --iterations "$ITERS" --resolution -1 --sh_degree 3 --eval
    python "${GS3D_ROOT}/render.py"  -m "$OUT" --skip_train
    python "${GS3D_ROOT}/metrics.py" -m "$OUT"
    echo "[${KEY}] 3DGS done → ${OUT}"
}

T="${1:-all}"
if [ "$T" = all ]; then for s in "${SCENES[@]}"; do train_scene "$s"; done
else train_scene "$T"; fi
