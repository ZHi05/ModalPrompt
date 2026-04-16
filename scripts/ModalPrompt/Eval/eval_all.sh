#!/bin/bash

# eval_all.sh 逻辑说明：
# 1) 前 8 行：每个 stage 的“当前任务性能”（Stage=t 时评估 task t）
# 2) 后续分组：每到新 stage，仅回测之前见过的任务（即 BWT 下三角评估）
#    例如 stage=4 (GQA) 时，评估 task1~task3；
#    stage=8 (OCRVQA) 时，评估 task1~task7。
# 3) 这份脚本默认是 CL 增量评估，不包含 zeroshot / multitask 上下界。
#    上下界请使用：
#    - scripts/ModalPrompt/Eval/eval_zeroshot_lowerbound.sh
#    - scripts/ModalPrompt/Eval/eval_multitask_upperbound.sh

sh scripts/ModalPrompt/Eval/1_eval_sqa.sh Finetune checkpoints/ModalPrompt/ScienceQA/llava-1.5-7b 1 8 
sh scripts/ModalPrompt/Eval/2_eval_textqa.sh Finetune checkpoints/ModalPrompt/TextVQA/llava-1.5-7b 2 8
sh scripts/ModalPrompt/Eval/3_eval_ImageNet.sh Finetune checkpoints/ModalPrompt/ImageNet/llava-1.5-7b 3 8
sh scripts/ModalPrompt/Eval/4_eval_gqa.sh Finetune checkpoints/ModalPrompt/GQA/llava-1.5-7b 4 8
sh scripts/ModalPrompt/Eval/5_eval_vizwiz.sh Finetune checkpoints/ModalPrompt/VizWiz/llava-1.5-7b 5 8
sh scripts/ModalPrompt/Eval/6_eval_grounding.sh Finetune checkpoints/ModalPrompt/Grounding/llava-1.5-7b 6 8
sh scripts/ModalPrompt/Eval/7_eval_vqav2.sh Finetune checkpoints/ModalPrompt/VQAv2/llava-1.5-7b 7 8
sh scripts/ModalPrompt/Eval/8_eval_ocrvqa.sh Finetune checkpoints/ModalPrompt/OCRVQA/llava-1.5-7b 8 8

sh scripts/ModalPrompt/Eval/1_eval_sqa.sh TextVQA checkpoints/ModalPrompt/TextVQA/llava-1.5-7b 2 8

sh scripts/ModalPrompt/Eval/1_eval_sqa.sh ImageNet checkpoints/ModalPrompt/ImageNet/llava-1.5-7b 3 8
sh scripts/ModalPrompt/Eval/2_eval_textqa.sh ImageNet checkpoints/ModalPrompt/ImageNet/llava-1.5-7b 3 8

sh scripts/ModalPrompt/Eval/1_eval_sqa.sh GQA checkpoints/ModalPrompt/GQA/llava-1.5-7b 4 8
sh scripts/ModalPrompt/Eval/2_eval_textqa.sh GQA checkpoints/ModalPrompt/GQA/llava-1.5-7b 4 8
sh scripts/ModalPrompt/Eval/3_eval_ImageNet.sh GQA checkpoints/ModalPrompt/GQA/llava-1.5-7b 4 8

sh scripts/ModalPrompt/Eval/1_eval_sqa.sh VizWiz checkpoints/ModalPrompt/VizWiz/llava-1.5-7b 5 8
sh scripts/ModalPrompt/Eval/2_eval_textqa.sh VizWiz checkpoints/ModalPrompt/VizWiz/llava-1.5-7b 5 8
sh scripts/ModalPrompt/Eval/3_eval_ImageNet.sh VizWiz checkpoints/ModalPrompt/VizWiz/llava-1.5-7b 5 8
sh scripts/ModalPrompt/Eval/4_eval_gqa.sh VizWiz checkpoints/ModalPrompt/VizWiz/llava-1.5-7b 5 8

sh scripts/ModalPrompt/Eval/1_eval_sqa.sh Grounding checkpoints/ModalPrompt/Grounding/llava-1.5-7b 6 8
sh scripts/ModalPrompt/Eval/2_eval_textqa.sh Grounding checkpoints/ModalPrompt/Grounding/llava-1.5-7b 6 8
sh scripts/ModalPrompt/Eval/3_eval_ImageNet.sh Grounding checkpoints/ModalPrompt/Grounding/llava-1.5-7b 6 8
sh scripts/ModalPrompt/Eval/4_eval_gqa.sh Grounding checkpoints/ModalPrompt/Grounding/llava-1.5-7b 6 8
sh scripts/ModalPrompt/Eval/5_eval_vizwiz.sh Grounding checkpoints/ModalPrompt/Grounding/llava-1.5-7b 6 8

sh scripts/ModalPrompt/Eval/1_eval_sqa.sh VQAv2 checkpoints/ModalPrompt/VQAv2/llava-1.5-7b 7 8
sh scripts/ModalPrompt/Eval/2_eval_textqa.sh VQAv2 checkpoints/ModalPrompt/VQAv2/llava-1.5-7b 7 8
sh scripts/ModalPrompt/Eval/3_eval_ImageNet.sh VQAv2 checkpoints/ModalPrompt/VQAv2/llava-1.5-7b 7 8
sh scripts/ModalPrompt/Eval/4_eval_gqa.sh VQAv2 checkpoints/ModalPrompt/VQAv2/llava-1.5-7b 7 8
sh scripts/ModalPrompt/Eval/5_eval_vizwiz.sh VQAv2 checkpoints/ModalPrompt/VQAv2/llava-1.5-7b 7 8
sh scripts/ModalPrompt/Eval/6_eval_grounding.sh VQAv2 checkpoints/ModalPrompt/VQAv2/llava-1.5-7b 7 8

sh scripts/ModalPrompt/Eval/1_eval_sqa.sh OCRVQA checkpoints/ModalPrompt/OCRVQA/llava-1.5-7b 8 8
sh scripts/ModalPrompt/Eval/2_eval_textqa.sh OCRVQA checkpoints/ModalPrompt/OCRVQA/llava-1.5-7b 8 8
sh scripts/ModalPrompt/Eval/3_eval_ImageNet.sh OCRVQA checkpoints/ModalPrompt/OCRVQA/llava-1.5-7b 8 8
sh scripts/ModalPrompt/Eval/4_eval_gqa.sh OCRVQA checkpoints/ModalPrompt/OCRVQA/llava-1.5-7b 8 8
sh scripts/ModalPrompt/Eval/5_eval_vizwiz.sh OCRVQA checkpoints/ModalPrompt/OCRVQA/llava-1.5-7b 8 8
sh scripts/ModalPrompt/Eval/6_eval_grounding.sh OCRVQA checkpoints/ModalPrompt/OCRVQA/llava-1.5-7b 8 8
sh scripts/ModalPrompt/Eval/7_eval_vqav2.sh OCRVQA checkpoints/ModalPrompt/OCRVQA/llava-1.5-7b 8 8
