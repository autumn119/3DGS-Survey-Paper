#!/usr/bin/env bash
# methods/nerf/train.sh
# Train NeRF (nerf-pytorch / bmild style) on one or all scenes.
#
# Usage:  bash train.sh <scene>
#         bash train.sh all
#
# Requires: nerf-pytorch cloned to $NERF_ROOT
#           (default: ~/nerf-pytorch)

set -euo pipefail

SCENES=(chaoli zeli chongjiang zengchong)
DATA_ROOT="$(dirname "$0")/../../../data"
NERF_ROOT="${NERF_ROOT:-$HOME/nerf-pytorch}"
ITERS=200000
N_ENCODE=10       # positional encoding bands

train_scene() {
    local SCENE="$1"
    local SOURCE="${DATA_ROOT}/${SCENE}/dense"
    local OUTPUT="${DATA_ROOT}/${SCENE}/output/nerf"
    echo "===== NeRF  [${SCENE}] ====="
    [ -d "$SOURCE" ] || { echo "ERROR: ${SOURCE} not found. Run run_sfm.sh first."; return 1; }
    mkdir -p "$OUTPUT"

    python "${NERF_ROOT}/run_nerf.py" \
        --config    "${NERF_ROOT}/configs/llff.txt" \
        --datadir   "$SOURCE" \
        --basedir   "$OUTPUT" \
        --expname   "${SCENE}_nerf" \
        --N_iters   "$ITERS" \
        --multires  "$N_ENCODE" \
        --lrate_decay 250 \
        --llffhold 8

    echo "[${SCENE}] NeRF training done → ${OUTPUT}"
}

TARGET="${1:-all}"
if [ "$TARGET" = "all" ]; then
    for s in "${SCENES[@]}"; do train_scene "$s"; done
else
    train_scene "$TARGET"
fi
