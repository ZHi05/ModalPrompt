#!/bin/bash
set -e

# Zero-shot lower bound:
# Evaluate base model before CL training on all 8 tasks.
# Usage:
#   sh scripts/ModalPrompt/Eval/eval_zeroshot_lowerbound.sh [MODEL_PATH]
# Example:
#   sh scripts/ModalPrompt/Eval/eval_zeroshot_lowerbound.sh models/llava_v1.5-7b

MODEL_PATH=${1:-models/llava_v1.5-7b}
STAGE=ZeroShot

# For base-model zero-shot, do not pass --model-base.
export MODEL_BASE=

sh scripts/ModalPrompt/Eval/1_eval_sqa.sh $STAGE $MODEL_PATH 1 1
sh scripts/ModalPrompt/Eval/2_eval_textqa.sh $STAGE $MODEL_PATH 1 1
sh scripts/ModalPrompt/Eval/3_eval_ImageNet.sh $STAGE $MODEL_PATH 1 1
sh scripts/ModalPrompt/Eval/4_eval_gqa.sh $STAGE $MODEL_PATH 1 1
sh scripts/ModalPrompt/Eval/5_eval_vizwiz.sh $STAGE $MODEL_PATH 1 1
sh scripts/ModalPrompt/Eval/6_eval_grounding.sh $STAGE $MODEL_PATH 1 1
sh scripts/ModalPrompt/Eval/7_eval_vqav2.sh $STAGE $MODEL_PATH 1 1
sh scripts/ModalPrompt/Eval/8_eval_ocrvqa.sh $STAGE $MODEL_PATH 1 1
