# ModalPrompt 多机多卡训练指南（中文）

本次已为以下脚本增加多机参数：

- `scripts/ModalPrompt/Train/0_Multitask.sh`
- `scripts/ModalPrompt/Train/1_Science.sh` ~ `8_OCRVQA.sh`
- `scripts/ModalPrompt/Train/train_all.sh`

核心能力：单机模式保持不变；当 `NNODES>1` 时自动切换为 deepspeed 多机启动参数。

---

## 1. 新增环境变量

- `NNODES`：总机器数，默认 `1`
- `NODE_RANK`：当前机器编号（从 0 开始），默认 `0`
- `MASTER_ADDR`：主节点（rank0）IP，默认 `127.0.0.1`
- `MASTER_PORT`：通信端口（已存在）
- `NUM_GPUS_PER_NODE`：每台机器 GPU 数，默认 `8`
- `GPUS`：本机 GPU 列表（如 `0,1,2,3,4,5,6,7`）

> 单机时可只传 `GPUS`，其余保持默认。

---

## 2. 多机 multitask 启动示例（2 机 x 8 卡）

假设：
- 节点0 IP：`10.10.10.1`
- 节点1 IP：`10.10.10.2`

在**节点0**执行：

```bash
cd /path/to/ModalPrompt
NNODES=2 NODE_RANK=0 MASTER_ADDR=10.10.10.1 MASTER_PORT=13200 \
NUM_GPUS_PER_NODE=8 GPUS=0,1,2,3,4,5,6,7 \
DS_CONFIG=./scripts/zero2.json NUM_WORKERS=32 \
sh scripts/ModalPrompt/Train/0_Multitask.sh
```

在**节点1**执行：

```bash
cd /path/to/ModalPrompt
NNODES=2 NODE_RANK=1 MASTER_ADDR=10.10.10.1 MASTER_PORT=13200 \
NUM_GPUS_PER_NODE=8 GPUS=0,1,2,3,4,5,6,7 \
DS_CONFIG=./scripts/zero2.json NUM_WORKERS=32 \
sh scripts/ModalPrompt/Train/0_Multitask.sh
```

---

## 3. 多机 CL 顺序训练（1~8 任务）

在每个节点分别执行 `train_all.sh`，只改 `NODE_RANK`：

```bash
cd /path/to/ModalPrompt
NNODES=2 NODE_RANK=0 MASTER_ADDR=10.10.10.1 MASTER_PORT=13200 \
NUM_GPUS_PER_NODE=8 GPUS=0,1,2,3,4,5,6,7 \
DS_CONFIG=./scripts/zero2.json NUM_WORKERS=32 SAVE_TOTAL_LIMIT=2 \
sh scripts/ModalPrompt/Train/train_all.sh
```

另一个节点：

```bash
cd /path/to/ModalPrompt
NNODES=2 NODE_RANK=1 MASTER_ADDR=10.10.10.1 MASTER_PORT=13200 \
NUM_GPUS_PER_NODE=8 GPUS=0,1,2,3,4,5,6,7 \
DS_CONFIG=./scripts/zero2.json NUM_WORKERS=32 SAVE_TOTAL_LIMIT=2 \
sh scripts/ModalPrompt/Train/train_all.sh
```

---

## 4. 输出目录说明

### multitask
- 模型输出：`checkpoints/ModalPrompt/Multitask/llava-1.5-7b`
- TensorBoard：`runs/ModalPrompt/Multitask`

### CL 任务
- Task1：`checkpoints/ModalPrompt/ScienceQA/llava-1.5-7b`
- Task2：`checkpoints/ModalPrompt/TextVQA/llava-1.5-7b`
- Task3：`checkpoints/ModalPrompt/ImageNet/llava-1.5-7b`
- Task4：`checkpoints/ModalPrompt/GQA/llava-1.5-7b`
- Task5：`checkpoints/ModalPrompt/VizWiz/llava-1.5-7b`
- Task6：`checkpoints/ModalPrompt/Grounding/llava-1.5-7b`
- Task7：`checkpoints/ModalPrompt/VQAv2/llava-1.5-7b`
- Task8：`checkpoints/ModalPrompt/OCRVQA/llava-1.5-7b`

---

## 5. 建议（针对你 46h 太慢场景）

1. 先优先跑多机 `0_Multitask.sh` 做对照，直接拉短总时长。  
2. `NUM_WORKERS` 建议从 32 起步。  
3. 如果网络带宽有限，优先保证数据在本地 NVMe，不走远程盘。  
4. 如需继续压时长，可把 `NUM_EPOCHS` 降低并保持同一配置做对照。  
