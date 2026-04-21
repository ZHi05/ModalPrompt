#!/bin/bash
set -e

# Zero-shot lower bound:
# Evaluate base model before CL training on all 8 tasks.
# Usage:
#   sh scripts/ModalPrompt/Eval/eval_zeroshot_lowerbound.sh [MODEL_PATH]
# Example:
#   sh scripts/ModalPrompt/Eval/eval_zeroshot_lowerbound.sh models/llava_v1.5-7b
# 参数约定：
# - MODEL_PATH: 要直接评测的模型目录
# - zeroshot 下不应传 --model-base（否则会走 CL checkpoint 加载分支）
# - GPUS: 逗号分隔的 CUDA 卡号，例如 0,1,2,3（默认 0）
# - SEED: 固定随机种子（默认 42）

MODEL_PATH=${1:-models/llava_v1.5-7b}
STAGE=ZeroShot
GPUS=${GPUS:-0}
SEED=${SEED:-42}

# For base-model zero-shot, do not pass --model-base.
export MODEL_BASE=

GPUS="$GPUS" SEED="$SEED" sh scripts/ModalPrompt/Eval/1_eval_sqa.sh $STAGE $MODEL_PATH 1 1
GPUS="$GPUS" SEED="$SEED" sh scripts/ModalPrompt/Eval/2_eval_textqa.sh $STAGE $MODEL_PATH 1 1
GPUS="$GPUS" SEED="$SEED" sh scripts/ModalPrompt/Eval/3_eval_ImageNet.sh $STAGE $MODEL_PATH 1 1
GPUS="$GPUS" SEED="$SEED" sh scripts/ModalPrompt/Eval/4_eval_gqa.sh $STAGE $MODEL_PATH 1 1
GPUS="$GPUS" SEED="$SEED" sh scripts/ModalPrompt/Eval/5_eval_vizwiz.sh $STAGE $MODEL_PATH 1 1
GPUS="$GPUS" SEED="$SEED" sh scripts/ModalPrompt/Eval/6_eval_grounding.sh $STAGE $MODEL_PATH 1 1
GPUS="$GPUS" SEED="$SEED" sh scripts/ModalPrompt/Eval/7_eval_vqav2.sh $STAGE $MODEL_PATH 1 1
GPUS="$GPUS" SEED="$SEED" sh scripts/ModalPrompt/Eval/8_eval_ocrvqa.sh $STAGE $MODEL_PATH 1 1
