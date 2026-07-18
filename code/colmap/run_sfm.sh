#!/usr/bin/env bash
# colmap/run_sfm.sh
# Run full COLMAP SfM pipeline for one scene.
#
# Usage:  bash run_sfm.sh <scene>
#         bash run_sfm.sh all
#
# Expects:  data/<scene>/images/   (output of prepare_images.py)
# Produces: data/<scene>/sparse/   (COLMAP model)
#           data/<scene>/dense/    (undistorted images for training)

set -euo pipefail

SCENES=(chaoli zeli chongjiang zengchong)
DATA_ROOT="$(dirname "$0")/../../data"

run_scene() {
    local SCENE="$1"
    local SCENE_DIR="${DATA_ROOT}/${SCENE}"
    local IMAGE_DIR="${SCENE_DIR}/images"
    local DB="${SCENE_DIR}/colmap.db"
    local SPARSE="${SCENE_DIR}/sparse"
    local DENSE="${SCENE_DIR}/dense"

    echo "========== [${SCENE}] =========="
    [ -d "$IMAGE_DIR" ] || { echo "ERROR: ${IMAGE_DIR} not found"; return 1; }
    mkdir -p "$SPARSE" "$DENSE"

    # 1. Feature extraction (SIFT + GPU, single-camera)
    colmap feature_extractor \
        --database_path "$DB" \
        --image_path "$IMAGE_DIR" \
        --ImageReader.single_camera 1 \
        --ImageReader.camera_model OPENCV \
        --SiftExtraction.use_gpu 1

    # 2. Sequential matching (suited for UAV video / ordered captures)
    colmap sequential_matcher \
        --database_path "$DB" \
        --SiftMatching.use_gpu 1

    # 3. Incremental SfM
    colmap mapper \
        --database_path "$DB" \
        --image_path "$IMAGE_DIR" \
        --output_path "$SPARSE"

    # 4. Undistort images (output used by all 4 methods)
    colmap image_undistorter \
        --image_path "$IMAGE_DIR" \
        --input_path  "${SPARSE}/0" \
        --output_path "$DENSE" \
        --output_type COLMAP

    echo "[${SCENE}] Done → ${DENSE}"
}

TARGET="${1:-all}"
if [ "$TARGET" = "all" ]; then
    for s in "${SCENES[@]}"; do run_scene "$s"; done
else
    run_scene "$TARGET"
fi
