#!/bin/bash
set -e

# 论文表 3 风格的 guidance 消融：
# - dual: 图像 + 文本双模态引导（默认原始设置）
# - image: 只保留图像引导
# - text: 只保留文本引导
#
# 用法：
#   sh scripts/ModalPrompt/Eval/eval_guidance_ablation.sh
#   GPUS=0,1,2,3 sh scripts/ModalPrompt/Eval/eval_guidance_ablation.sh
#   GUIDANCE_MODES="dual image text" sh scripts/ModalPrompt/Eval/eval_guidance_ablation.sh

GPUS=${GPUS:-0}
SEED=${SEED:-42}
RESULT_BASE=${RESULT_BASE:-./results}
GUIDANCE_MODES=${GUIDANCE_MODES:-"dual image text"}

for GUIDANCE_MODE in $GUIDANCE_MODES; do
    RESULT_ROOT="${RESULT_BASE}/ModalPrompt_guidance_${GUIDANCE_MODE}"
    echo "=================================================="
    echo "开始评测 guidance_mode=${GUIDANCE_MODE}"
    echo "结果目录: ${RESULT_ROOT}"
    echo "=================================================="
    GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" \
        sh scripts/ModalPrompt/Eval/eval_all.sh
done
