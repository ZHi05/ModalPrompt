#!/bin/bash
set -e

# Multitask upper bound:
# Evaluate a jointly trained multitask checkpoint on all 8 tasks.
# Default checkpoint is from scripts/ModalPrompt/Train/0_Multitask.sh
# Usage:
#   sh scripts/ModalPrompt/Eval/eval_multitask_upperbound.sh [MODEL_PATH]

MODEL_PATH=${1:-checkpoints/ModalPrompt/Multitask/llava-1.5-7b}
STAGE=Multitask

sh scripts/ModalPrompt/Eval/1_eval_sqa.sh $STAGE $MODEL_PATH 1 1
sh scripts/ModalPrompt/Eval/2_eval_textqa.sh $STAGE $MODEL_PATH 1 1
sh scripts/ModalPrompt/Eval/3_eval_ImageNet.sh $STAGE $MODEL_PATH 1 1
sh scripts/ModalPrompt/Eval/4_eval_gqa.sh $STAGE $MODEL_PATH 1 1
sh scripts/ModalPrompt/Eval/5_eval_vizwiz.sh $STAGE $MODEL_PATH 1 1
sh scripts/ModalPrompt/Eval/6_eval_grounding.sh $STAGE $MODEL_PATH 1 1
sh scripts/ModalPrompt/Eval/7_eval_vqav2.sh $STAGE $MODEL_PATH 1 1
sh scripts/ModalPrompt/Eval/8_eval_ocrvqa.sh $STAGE $MODEL_PATH 1 1
