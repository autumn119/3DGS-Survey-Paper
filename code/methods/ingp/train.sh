#!/usr/bin/env bash
# methods/ingp/train.sh — Instant-NGP
# Repo on server: /root/autodl-tmp/instant-ngp
#
# Usage:  bash train.sh <scene|all>
# Input:  datasets/guloushuju/<scene>/ingp  (transforms.json ready)
# Output: output/<scene>/ingp  (model_*.msgpack + training_log.json)
#
# Server produced checkpoints at 10k/20k/.../50k → n_steps=50000.
set -euo pipefail
source "$(dirname "$0")/../../scenes.sh"

STEPS=50000

train_scene() {
    local KEY="$1"
    local SRC; SRC="$(scene_dir "$KEY")/ingp"
    local OUT="${OUTPUT_ROOT}/${CN_NAME[$KEY]:-$KEY}/ingp"
    echo "===== INGP  [${KEY}] ====="
    [ -f "${SRC}/transforms.json" ] || { echo "ERROR: ${SRC}/transforms.json missing"; return 1; }
    mkdir -p "$OUT"

    # Multiresolution hash encoding (16 log2 levels, default INGP config)
    python "${INGP_ROOT}/scripts/run.py" \
        --scene "${SRC}/transforms.json" \
        --mode nerf --n_steps "$STEPS" \
        --save_snapshot "${OUT}/model_final.msgpack" \
        --test_transforms "${SRC}/transforms_test_llff.json" \
        --screenshot_dir "${OUT}/test_renders"
    echo "[${KEY}] INGP done → ${OUT}"
}

T="${1:-all}"
if [ "$T" = all ]; then for s in "${SCENES[@]}"; do train_scene "$s"; done
else train_scene "$T"; fi
