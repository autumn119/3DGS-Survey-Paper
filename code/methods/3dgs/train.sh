#!/usr/bin/env bash
# methods/3dgs/train.sh
# Train 3D Gaussian Splatting on one or all scenes.
#
# Usage:  bash train.sh <scene>
#         bash train.sh all
#
# Requires: graphdeco-inria/gaussian-splatting cloned to $GS3D_ROOT
#           (default: ~/gaussian-splatting)

set -euo pipefail

SCENES=(chaoli zeli chongjiang zengchong)
DATA_ROOT="$(dirname "$0")/../../../data"
GS3D_ROOT="${GS3D_ROOT:-$HOME/gaussian-splatting}"
ITERS=30000
RESOLUTION=2      # half resolution (1920×1080 → 960×540)

train_scene() {
    local SCENE="$1"
    local SOURCE="${DATA_ROOT}/${SCENE}/dense"
    local OUTPUT="${DATA_ROOT}/${SCENE}/output/3dgs"
    echo "===== 3DGS  [${SCENE}] ====="
    [ -d "$SOURCE" ] || { echo "ERROR: ${SOURCE} not found. Run run_sfm.sh first."; return 1; }
    mkdir -p "$OUTPUT"

    python "${GS3D_ROOT}/train.py" \
        -s "$SOURCE" \
        -m "$OUTPUT" \
        --iterations "$ITERS" \
        --resolution  "$RESOLUTION" \
        --eval

    echo "[${SCENE}] 3DGS training done → ${OUTPUT}"
}

TARGET="${1:-all}"
if [ "$TARGET" = "all" ]; then
    for s in "${SCENES[@]}"; do train_scene "$s"; done
else
    train_scene "$TARGET"
fi
