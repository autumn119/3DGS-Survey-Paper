#!/usr/bin/env bash
# scenes.sh — shared scene configuration (source this from other scripts)
#
# Four Dong Drum Tower scenes. English (pinyin) name is the canonical key;
# CN_NAME is the on-disk directory name used on the training server.
#
#   pinyin      chinese   #images
#   celi        则里       654
#   zhaoli      朝利       544
#   congjiang   从江       551
#   zhengchong  增冲       (frames extracted, images_4 used)

SCENES=(celi zhaoli congjiang zhengchong)

# pinyin -> chinese directory name (edit here if your dataset uses pinyin dirs)
declare -A CN_NAME=(
    [celi]=则里
    [zhaoli]=朝利
    [congjiang]=从江
    [zhengchong]=增冲
)

# Root paths (override via environment variables before sourcing if needed)
DATA_ROOT="${DATA_ROOT:-/root/autodl-tmp/datasets/guloushuju}"
OUTPUT_ROOT="${OUTPUT_ROOT:-/root/autodl-tmp/output}"

# Method repositories on the training server
GS2D_ROOT="${GS2D_ROOT:-/root/autodl-tmp/2d-gaussian-splatting}"
GS3D_ROOT="${GS3D_ROOT:-/root/autodl-tmp/gaussian-splatting}"   # 3DGS (clone here)
NERF_ROOT="${NERF_ROOT:-/root/autodl-tmp/autodl-envs/nerf}"
INGP_ROOT="${INGP_ROOT:-/root/autodl-tmp/instant-ngp}"

# Resolve the on-disk scene directory for a pinyin key
scene_dir() {
    local key="$1"
    echo "${DATA_ROOT}/${CN_NAME[$key]:-$key}"
}
