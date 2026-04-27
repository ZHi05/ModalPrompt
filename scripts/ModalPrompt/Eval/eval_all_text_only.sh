#!/bin/bash

# 文本单模态消融评测入口。
# 对应训练入口：sh scripts/ModalPrompt/Train/Ablation/train_text_only.sh
#
# - 使用 guidance_mode=text 进行推理
# - 检查点目录：checkpoints/ModalPrompt_TextOnly/<Task>/llava-1.5-7b
#
# 评测逻辑与 eval_all.sh 完全相同，包含：
#   1) 每个 stage 的当前任务性能（Stage=t 时评估 task t）
#   2) BWT 下三角评估（回测已见任务）
#
# 用法：
#   sh scripts/ModalPrompt/Eval/eval_all_text_only.sh
#   GPUS=0,1,2,3 sh scripts/ModalPrompt/Eval/eval_all_text_only.sh

GPUS=${GPUS:-0}
SEED=${SEED:-42}
GUIDANCE_MODE=text
RESULT_ROOT=${RESULT_ROOT:-./results/ModalPrompt_TextOnly}

GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/1_eval_sqa.sh Finetune checkpoints/ModalPrompt_TextOnly/ScienceQA/llava-1.5-7b 1 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/2_eval_textqa.sh Finetune checkpoints/ModalPrompt_TextOnly/TextVQA/llava-1.5-7b 2 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/3_eval_ImageNet.sh Finetune checkpoints/ModalPrompt_TextOnly/ImageNet/llava-1.5-7b 3 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/4_eval_gqa.sh Finetune checkpoints/ModalPrompt_TextOnly/GQA/llava-1.5-7b 4 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/5_eval_vizwiz.sh Finetune checkpoints/ModalPrompt_TextOnly/VizWiz/llava-1.5-7b 5 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/6_eval_grounding.sh Finetune checkpoints/ModalPrompt_TextOnly/Grounding/llava-1.5-7b 6 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/7_eval_vqav2.sh Finetune checkpoints/ModalPrompt_TextOnly/VQAv2/llava-1.5-7b 7 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/8_eval_ocrvqa.sh Finetune checkpoints/ModalPrompt_TextOnly/OCRVQA/llava-1.5-7b 8 8

GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/1_eval_sqa.sh TextVQA checkpoints/ModalPrompt_TextOnly/TextVQA/llava-1.5-7b 2 8

GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/1_eval_sqa.sh ImageNet checkpoints/ModalPrompt_TextOnly/ImageNet/llava-1.5-7b 3 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/2_eval_textqa.sh ImageNet checkpoints/ModalPrompt_TextOnly/ImageNet/llava-1.5-7b 3 8

GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/1_eval_sqa.sh GQA checkpoints/ModalPrompt_TextOnly/GQA/llava-1.5-7b 4 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/2_eval_textqa.sh GQA checkpoints/ModalPrompt_TextOnly/GQA/llava-1.5-7b 4 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/3_eval_ImageNet.sh GQA checkpoints/ModalPrompt_TextOnly/GQA/llava-1.5-7b 4 8

GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/1_eval_sqa.sh VizWiz checkpoints/ModalPrompt_TextOnly/VizWiz/llava-1.5-7b 5 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/2_eval_textqa.sh VizWiz checkpoints/ModalPrompt_TextOnly/VizWiz/llava-1.5-7b 5 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/3_eval_ImageNet.sh VizWiz checkpoints/ModalPrompt_TextOnly/VizWiz/llava-1.5-7b 5 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/4_eval_gqa.sh VizWiz checkpoints/ModalPrompt_TextOnly/VizWiz/llava-1.5-7b 5 8

GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/1_eval_sqa.sh Grounding checkpoints/ModalPrompt_TextOnly/Grounding/llava-1.5-7b 6 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/2_eval_textqa.sh Grounding checkpoints/ModalPrompt_TextOnly/Grounding/llava-1.5-7b 6 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/3_eval_ImageNet.sh Grounding checkpoints/ModalPrompt_TextOnly/Grounding/llava-1.5-7b 6 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/4_eval_gqa.sh Grounding checkpoints/ModalPrompt_TextOnly/Grounding/llava-1.5-7b 6 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/5_eval_vizwiz.sh Grounding checkpoints/ModalPrompt_TextOnly/Grounding/llava-1.5-7b 6 8

GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/1_eval_sqa.sh VQAv2 checkpoints/ModalPrompt_TextOnly/VQAv2/llava-1.5-7b 7 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/2_eval_textqa.sh VQAv2 checkpoints/ModalPrompt_TextOnly/VQAv2/llava-1.5-7b 7 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/3_eval_ImageNet.sh VQAv2 checkpoints/ModalPrompt_TextOnly/VQAv2/llava-1.5-7b 7 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/4_eval_gqa.sh VQAv2 checkpoints/ModalPrompt_TextOnly/VQAv2/llava-1.5-7b 7 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/5_eval_vizwiz.sh VQAv2 checkpoints/ModalPrompt_TextOnly/VQAv2/llava-1.5-7b 7 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/6_eval_grounding.sh VQAv2 checkpoints/ModalPrompt_TextOnly/VQAv2/llava-1.5-7b 7 8

GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/1_eval_sqa.sh OCRVQA checkpoints/ModalPrompt_TextOnly/OCRVQA/llava-1.5-7b 8 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/2_eval_textqa.sh OCRVQA checkpoints/ModalPrompt_TextOnly/OCRVQA/llava-1.5-7b 8 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/3_eval_ImageNet.sh OCRVQA checkpoints/ModalPrompt_TextOnly/OCRVQA/llava-1.5-7b 8 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/4_eval_gqa.sh OCRVQA checkpoints/ModalPrompt_TextOnly/OCRVQA/llava-1.5-7b 8 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/5_eval_vizwiz.sh OCRVQA checkpoints/ModalPrompt_TextOnly/OCRVQA/llava-1.5-7b 8 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/6_eval_grounding.sh OCRVQA checkpoints/ModalPrompt_TextOnly/OCRVQA/llava-1.5-7b 8 8
GPUS="$GPUS" SEED="$SEED" GUIDANCE_MODE="$GUIDANCE_MODE" RESULT_ROOT="$RESULT_ROOT" sh scripts/ModalPrompt/Eval/7_eval_vqav2.sh OCRVQA checkpoints/ModalPrompt_TextOnly/OCRVQA/llava-1.5-7b 8 8
