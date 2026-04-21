#!/bin/bash
set -e

# CL 顺序训练入口（task1 -> task8）。
# 若需要 multitask 上界，请单独运行：
#   sh scripts/ModalPrompt/Train/0_Multitask.sh
# 全局参数（可在命令前覆盖）：
#   GPUS=0,1,2,3,4,5,6,7
#   DS_CONFIG=./scripts/zero2.json
#   MASTER_PORT=13200
#   SEED=42
#   NUM_WORKERS=16
GPUS=${GPUS:-0,1,2,3,4,5,6,7}
DS_CONFIG=${DS_CONFIG:-./scripts/zero2.json}
MASTER_PORT=${MASTER_PORT:-13200}
SEED=${SEED:-42}
NUM_WORKERS=${NUM_WORKERS:-16}

GPUS="$GPUS" DS_CONFIG="$DS_CONFIG" MASTER_PORT="$MASTER_PORT" SEED="$SEED" NUM_WORKERS="$NUM_WORKERS" sh ./scripts/ModalPrompt/Train/1_Science.sh
GPUS="$GPUS" DS_CONFIG="$DS_CONFIG" MASTER_PORT="$MASTER_PORT" SEED="$SEED" NUM_WORKERS="$NUM_WORKERS" sh ./scripts/ModalPrompt/Train/2_TextVQA.sh
GPUS="$GPUS" DS_CONFIG="$DS_CONFIG" MASTER_PORT="$MASTER_PORT" SEED="$SEED" NUM_WORKERS="$NUM_WORKERS" sh ./scripts/ModalPrompt/Train/3_ImageNet.sh
GPUS="$GPUS" DS_CONFIG="$DS_CONFIG" MASTER_PORT="$MASTER_PORT" SEED="$SEED" NUM_WORKERS="$NUM_WORKERS" sh ./scripts/ModalPrompt/Train/4_GQA.sh
GPUS="$GPUS" DS_CONFIG="$DS_CONFIG" MASTER_PORT="$MASTER_PORT" SEED="$SEED" NUM_WORKERS="$NUM_WORKERS" sh ./scripts/ModalPrompt/Train/5_VizWiz.sh
GPUS="$GPUS" DS_CONFIG="$DS_CONFIG" MASTER_PORT="$MASTER_PORT" SEED="$SEED" NUM_WORKERS="$NUM_WORKERS" sh ./scripts/ModalPrompt/Train/6_Grounding.sh
GPUS="$GPUS" DS_CONFIG="$DS_CONFIG" MASTER_PORT="$MASTER_PORT" SEED="$SEED" NUM_WORKERS="$NUM_WORKERS" sh ./scripts/ModalPrompt/Train/7_vqav2.sh
GPUS="$GPUS" DS_CONFIG="$DS_CONFIG" MASTER_PORT="$MASTER_PORT" SEED="$SEED" NUM_WORKERS="$NUM_WORKERS" sh ./scripts/ModalPrompt/Train/8_OCRVQA.sh
