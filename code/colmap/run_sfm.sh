#!/usr/bin/env bash
# colmap/run_sfm.sh — COLMAP SfM for one scene (COLMAP 3.14.0, CUDA)
#
# Usage:  bash run_sfm.sh <scene|all>
# Input:  datasets/guloushuju/<scene>/images/  (frame_XXXXXX.jpg)
# Output: datasets/guloushuju/<scene>/sparse/  + dense/
#
# On the training server this step is already done: each method folder
# (2dgs/nerf/ingp) ships with its own colmap_ws. Re-run this only to
# regenerate the shared sparse model from scratch.
set -euo pipefail
source "$(dirname "$0")/../scenes.sh"

run_scene() {
    local KEY="$1"
    local SDIR; SDIR="$(scene_dir "$KEY")"
    local IMG="${SDIR}/images"
    local DB="${SDIR}/colmap.db"
    local SPARSE="${SDIR}/sparse"
    local DENSE="${SDIR}/dense"
    echo "===== COLMAP  [${KEY}] ====="
    [ -d "$IMG" ] || { echo "ERROR: ${IMG} not found"; return 1; }
    mkdir -p "$SPARSE" "$DENSE"

    colmap feature_extractor --database_path "$DB" --image_path "$IMG" \
        --ImageReader.single_camera 1 --ImageReader.camera_model OPENCV \
        --SiftExtraction.use_gpu 1
    colmap sequential_matcher --database_path "$DB" --SiftMatching.use_gpu 1
    colmap mapper --database_path "$DB" --image_path "$IMG" --output_path "$SPARSE"
    colmap image_undistorter --image_path "$IMG" --input_path "${SPARSE}/0" \
        --output_path "$DENSE" --output_type COLMAP
    echo "[${KEY}] COLMAP done → ${DENSE}"
}

T="${1:-all}"
if [ "$T" = all ]; then for s in "${SCENES[@]}"; do run_scene "$s"; done
else run_scene "$T"; fi
