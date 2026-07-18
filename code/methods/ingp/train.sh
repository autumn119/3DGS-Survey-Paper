#!/usr/bin/env bash
# methods/ingp/train.sh
# Train Instant-NGP on one or all scenes.
#
# Usage:  bash train.sh <scene>
#         bash train.sh all
#
# Requires: Instant-NGP v2.0dev built to $INGP_ROOT
#           (default: ~/instant-ngp)

set -euo pipefail

SCENES=(chaoli zeli chongjiang zengchong)
DATA_ROOT="$(dirname "$0")/../../../data"
INGP_ROOT="${INGP_ROOT:-$HOME/instant-ngp}"

train_scene() {
    local SCENE="$1"
    local SOURCE="${DATA_ROOT}/${SCENE}/dense"
    local OUTPUT="${DATA_ROOT}/${SCENE}/output/ingp"
    echo "===== INGP  [${SCENE}] ====="
    [ -d "$SOURCE" ] || { echo "ERROR: ${SOURCE} not found. Run run_sfm.sh first."; return 1; }
    mkdir -p "$OUTPUT"

    # Convert COLMAP output to INGP transforms.json
    python "${INGP_ROOT}/scripts/colmap2nerf.py" \
        --colmap_db     "${DATA_ROOT}/${SCENE}/colmap.db" \
        --images        "${SOURCE}/images" \
        --text          "${SOURCE}/sparse" \
        --out           "${OUTPUT}/transforms.json" \
        --aabb_scale 16

    # Train with multiresolution hash encoding (16 log levels, default)
    "${INGP_ROOT}/build/testbed" \
        --scene       "${OUTPUT}/transforms.json" \
        --save_snapshot "${OUTPUT}/snapshot.msgpack" \
        --n_steps     35000 \
        --mode        nerf

    echo "[${SCENE}] INGP training done → ${OUTPUT}"
}

TARGET="${1:-all}"
if [ "$TARGET" = "all" ]; then
    for s in "${SCENES[@]}"; do train_scene "$s"; done
else
    train_scene "$TARGET"
fi
