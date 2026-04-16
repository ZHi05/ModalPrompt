# ModalPrompt 仓库 Copilot 指南

## 构建、测试、Lint 命令

### 环境与安装
```bash
conda create -n modalprompt python=3.10 -y
conda activate modalprompt
pip install --upgrade pip
pip install -e .
pip install -e ".[train]"
pip install flash-attn --no-build-isolation
```

### 全量训练流程（8 个连续任务）
```bash
sh scripts/ModalPrompt/Train/train_all.sh
```

### 全量评测流程（所有阶段/任务）
```bash
sh scripts/ModalPrompt/Eval/eval_all.sh
```

### 单任务评测（作为“单测/冒烟测试”入口）
```bash
sh scripts/ModalPrompt/Eval/1_eval_sqa.sh Finetune checkpoints/ModalPrompt/ScienceQA/llava-1.5-7b 1 8
```

仓库内未配置独立 lint 命令（未发现 ruff/flake8/black 配置或 lint 脚本）。

## 高层架构（跨文件要点）

- **主要入口是 shell 脚本**：`scripts/ModalPrompt/Train/` 与 `scripts/ModalPrompt/Eval/`。真实实验通常从这些脚本启动，并在脚本中改路径与任务参数。
- **训练主链路**：`llava/train/train_mem.py` → `llava/train/train.py`。
  - `train.py` 会初始化 `ModalPrompt`（不是原版 LLaVA）、设置连续学习 prompt token、当前任务、CLIP 视觉/文本塔，并交给 `LLaVATrainer` 训练。
  - `LLaVATrainer` 里有本仓库特有逻辑：`prompt_transform/embed_tokens/mm_projector` 的优化器分组、额外余弦损失、以及 embedding 重置逻辑。
- **ModalPrompt 核心实现位置**：
  - 任务 prompt token 与任务变换层：`llava/model/language_model/ModalPrompt.py`
  - 双模态引导的 prompt 选择/拼接：`llava/model/llava_arch.py` 中 `prepare_inputs_labels_for_multimodal`
- **评测主链路**：
  - `llava/eval/ModalPrompt/model_*.py` 负责生成答案，内部统一调用 `llava.model.builder.load_pretrained_model(...)`
  - `eval_*.py` 负责读取合并后的 JSONL 并计算各数据集指标
- **检查点组织方式**：
  - 持续 prompt tuning 会在每个任务目录保存 `non_lora_trainables.bin` + config（例如 `checkpoints/ModalPrompt/<Task>/llava-1.5-7b`）
  - 下一任务通过 `--previous_task_model_path` 读取上一任务权重继续训练

## 关键约定（本仓库特有）

- **ModalPrompt 实验默认只走 Prompt Tuning**：`train.py` 中显式断言 `lora_enable == False` 且 `pt_enable == True`。
- **任务编号从 1 开始**：`cur_task >= 1`。训练与评测时 `cur_task / num_tasks / prefix_len` 必须保持一致。
- **配置必须包含文本塔字段**：评测依赖 `mm_text_tower` 与 `mm_text_select_layer`（参考 `config.json` 与 README 的 Evaluation 说明）。
- **脚本路径默认是硬编码目录**：`models/`、`datasets/`、`instructions/`、`checkpoints/`、`results/`。通常优先改 shell 脚本路径，而不是改 Python 默认参数。
- **对话模板默认 Vicuna v1**：评测脚本普遍使用 `--conv-mode vicuna_v1`，图文输入依赖 `<image>` token 的预处理逻辑。
