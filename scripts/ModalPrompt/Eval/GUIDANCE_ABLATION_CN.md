# Guidance 消融说明

## 目的

该消融对应论文中“双模态引导有效性”的实验，只在 **评测 / 推理阶段** 切换引导方式，不改训练逻辑。

支持三种模式：

- `dual`：图像引导 + 文本引导
- `image`：只保留图像引导
- `text`：只保留文本引导

默认模式为 `dual`，因此原有评测命令不受影响。

## 使用方式

### 1. 跑单个评测脚本

例如只评测 ScienceQA：

```bash
GUIDANCE_MODE=image \
sh scripts/ModalPrompt/Eval/1_eval_sqa.sh Finetune checkpoints/ModalPrompt/ScienceQA/llava-1.5-7b 1 8
```

例如只评测 Grounding：

```bash
GUIDANCE_MODE=text \
sh scripts/ModalPrompt/Eval/6_eval_grounding.sh Finetune checkpoints/ModalPrompt/Grounding/llava-1.5-7b 6 8
```

### 2. 跑完整 `eval_all`

```bash
GUIDANCE_MODE=dual \
RESULT_ROOT=./results/ModalPrompt_guidance_dual \
sh scripts/ModalPrompt/Eval/eval_all.sh
```

```bash
GUIDANCE_MODE=image \
RESULT_ROOT=./results/ModalPrompt_guidance_image \
sh scripts/ModalPrompt/Eval/eval_all.sh
```

```bash
GUIDANCE_MODE=text \
RESULT_ROOT=./results/ModalPrompt_guidance_text \
sh scripts/ModalPrompt/Eval/eval_all.sh
```

### 3. 一次性跑完三组消融

```bash
GPUS=0,1,2,3 \
sh scripts/ModalPrompt/Eval/eval_guidance_ablation.sh
```

默认会依次写入：

- `./results/ModalPrompt_guidance_dual`
- `./results/ModalPrompt_guidance_image`
- `./results/ModalPrompt_guidance_text`

## 结果目录

每种模式都会保留和原始 `eval_all.sh` 一样的目录结构，只是根目录不同。

例如：

- `./results/ModalPrompt_guidance_dual/ScienceQA/...`
- `./results/ModalPrompt_guidance_image/ScienceQA/...`
- `./results/ModalPrompt_guidance_text/ScienceQA/...`

这样可以直接横向对比同一任务、同一 stage 下不同 guidance 的结果，而不会覆盖原始结果。

## 额外说明

- 现在评测脚本会默认设置 `TOKENIZERS_PARALLELISM=false`，用于关闭 `huggingface/tokenizers` 的 fork 警告。
- 如果你只想复现实验表 3，可以优先比较 `dual / image / text` 三组在最终 stage 或平均指标上的差异。
