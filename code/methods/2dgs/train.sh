#!/usr/bin/env bash
# methods/2dgs/train.sh
# Train 2D Gaussian Splatting on one or all scenes.
#
# Usage:  bash train.sh <scene>
#         bash train.sh all
#
# Requires: hbb1/2d-gaussian-splatting cloned to $GS2D_ROOT
#           (default: ~/2d-gaussian-splatting)

set -euo pipefail

SCENES=(chaoli zeli chongjiang zengchong)
DATA_ROOT="$(dirname "$0")/../../../data"
GS2D_ROOT="${GS2D_ROOT:-$HOME/2d-gaussian-splatting}"
ITERS=30000
RESOLUTION=2      # half resolution

train_scene() {
    local SCENE="$1"
    local SOURCE="${DATA_ROOT}/${SCENE}/dense"
    local OUTPUT="${DATA_ROOT}/${SCENE}/output/2dgs"
    echo "===== 2DGS  [${SCENE}] ====="
    [ -d "$SOURCE" ] || { echo "ERROR: ${SOURCE} not found. Run run_sfm.sh first."; return 1; }
    mkdir -p "$OUTPUT"

    python "${GS2D_ROOT}/train.py" \
        -s "$SOURCE" \
        -m "$OUTPUT" \
        --iterations  "$ITERS" \
        --resolution  "$RESOLUTION" \
        --depth_ratio 1.0 \
        --eval

    echo "[${SCENE}] 2DGS training done → ${OUTPUT}"
}

TARGET="${1:-all}"
if [ "$TARGET" = "all" ]; then
    for s in "${SCENES[@]}"; do train_scene "$s"; done
else
    train_scene "$TARGET"
fi
