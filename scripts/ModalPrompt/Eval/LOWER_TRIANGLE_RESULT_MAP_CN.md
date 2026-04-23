# eval_all 下三角评估结果索引（中文）

本文用于快速定位 `scripts/ModalPrompt/Eval/eval_all.sh` 跑完后，每一个下三角评估结果应去哪个文件看。

## 1) 规则先看

- `eval_all.sh` 一共跑 36 次评估（8 个对角 + 28 个下三角回测）。
- `STAGE` 是输出目录的第二级目录名（例如 `Finetune`、`GQA`、`OCRVQA`）。
- 每次评估的主结果文件在：
  - ScienceQA：`output_result.jsonl`
  - 其他任务：`Result.text`

## 2) 各任务“主结果文件”模板

- ScienceQA：`results/ModalPrompt/ScienceQA/<STAGE>/output_result.jsonl`
- TextVQA：`results/ModalPrompt/TextVQA/<STAGE>/Result.text`
- ImageNet：`results/ModalPrompt/ImageNet/<STAGE>/Result.text`
- GQA：`results/ModalPrompt/GQA/<STAGE>/Result.text`
- VizWiz：`results/ModalPrompt/VizWiz/<STAGE>/Result.text`
- Grounding：`results/ModalPrompt/Grounding/<STAGE>/Result.text`
- VQAv2：`results/ModalPrompt/VQAv2/<STAGE>/Result.text`
- OCRVQA：`results/ModalPrompt/OCRVQA/<STAGE>/Result.text`

> 补充：每个目录里还会有 `merge.jsonl` 和分片 `*_*.jsonl`（推理原始输出）；GQA/VQAv2/VizWiz 还有提交格式转换文件。

## 3) 36 个下三角评估逐项索引（按 `eval_all.sh` 顺序）

### Stage = `Finetune`（8 项）
- Task1 ScienceQA -> `results/ModalPrompt/ScienceQA/Finetune/output_result.jsonl`
- Task2 TextVQA -> `results/ModalPrompt/TextVQA/Finetune/Result.text`
- Task3 ImageNet -> `results/ModalPrompt/ImageNet/Finetune/Result.text`
- Task4 GQA -> `results/ModalPrompt/GQA/Finetune/Result.text`
- Task5 VizWiz -> `results/ModalPrompt/VizWiz/Finetune/Result.text`
- Task6 Grounding -> `results/ModalPrompt/Grounding/Finetune/Result.text`
- Task7 VQAv2 -> `results/ModalPrompt/VQAv2/Finetune/Result.text`
- Task8 OCRVQA -> `results/ModalPrompt/OCRVQA/Finetune/Result.text`

### Stage = `TextVQA`（1 项）
- Task1 ScienceQA -> `results/ModalPrompt/ScienceQA/TextVQA/output_result.jsonl`

### Stage = `ImageNet`（2 项）
- Task1 ScienceQA -> `results/ModalPrompt/ScienceQA/ImageNet/output_result.jsonl`
- Task2 TextVQA -> `results/ModalPrompt/TextVQA/ImageNet/Result.text`

### Stage = `GQA`（3 项）
- Task1 ScienceQA -> `results/ModalPrompt/ScienceQA/GQA/output_result.jsonl`
- Task2 TextVQA -> `results/ModalPrompt/TextVQA/GQA/Result.text`
- Task3 ImageNet -> `results/ModalPrompt/ImageNet/GQA/Result.text`

### Stage = `VizWiz`（4 项）
- Task1 ScienceQA -> `results/ModalPrompt/ScienceQA/VizWiz/output_result.jsonl`
- Task2 TextVQA -> `results/ModalPrompt/TextVQA/VizWiz/Result.text`
- Task3 ImageNet -> `results/ModalPrompt/ImageNet/VizWiz/Result.text`
- Task4 GQA -> `results/ModalPrompt/GQA/VizWiz/Result.text`

### Stage = `Grounding`（5 项）
- Task1 ScienceQA -> `results/ModalPrompt/ScienceQA/Grounding/output_result.jsonl`
- Task2 TextVQA -> `results/ModalPrompt/TextVQA/Grounding/Result.text`
- Task3 ImageNet -> `results/ModalPrompt/ImageNet/Grounding/Result.text`
- Task4 GQA -> `results/ModalPrompt/GQA/Grounding/Result.text`
- Task5 VizWiz -> `results/ModalPrompt/VizWiz/Grounding/Result.text`

### Stage = `VQAv2`（6 项）
- Task1 ScienceQA -> `results/ModalPrompt/ScienceQA/VQAv2/output_result.jsonl`
- Task2 TextVQA -> `results/ModalPrompt/TextVQA/VQAv2/Result.text`
- Task3 ImageNet -> `results/ModalPrompt/ImageNet/VQAv2/Result.text`
- Task4 GQA -> `results/ModalPrompt/GQA/VQAv2/Result.text`
- Task5 VizWiz -> `results/ModalPrompt/VizWiz/VQAv2/Result.text`
- Task6 Grounding -> `results/ModalPrompt/Grounding/VQAv2/Result.text`

### Stage = `OCRVQA`（7 项）
- Task1 ScienceQA -> `results/ModalPrompt/ScienceQA/OCRVQA/output_result.jsonl`
- Task2 TextVQA -> `results/ModalPrompt/TextVQA/OCRVQA/Result.text`
- Task3 ImageNet -> `results/ModalPrompt/ImageNet/OCRVQA/Result.text`
- Task4 GQA -> `results/ModalPrompt/GQA/OCRVQA/Result.text`
- Task5 VizWiz -> `results/ModalPrompt/VizWiz/OCRVQA/Result.text`
- Task6 Grounding -> `results/ModalPrompt/Grounding/OCRVQA/Result.text`
- Task7 VQAv2 -> `results/ModalPrompt/VQAv2/OCRVQA/Result.text`

## 4) 一眼看总结果的建议

- 先看各文件里的 `Accuracy`。
- ScienceQA 看 `output_result.jsonl` 的 `acc` 字段。
- 如果某项缺失，先检查对应目录里是否有 `merge.jsonl`（有则可重跑分析）。
