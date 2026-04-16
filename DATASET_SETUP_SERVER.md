# ModalPrompt 数据集准备（服务器版，含 ImageNet256 替代方案）

> 本文档只给出可在服务器执行的步骤，不会在本地机器执行训练/评测。  
> 目标是对齐本仓库脚本默认路径：`datasets/` 与 `instructions/`。

## 1. 目录约定（与仓库脚本一致）

在仓库根目录执行：

```bash
cd /path/to/ModalPrompt  # 改成你的仓库绝对路径
mkdir -p datasets instructions downloads
```

训练脚本默认读取：

- `instructions/<Task>/train.json`
- `datasets/`（`image` 字段是相对 `datasets/` 的路径）

评测脚本默认读取：

- `instructions/<Task>/{test.json|val.json}`
- 部分任务还需要原始标注文件（见第 4 节）

---

## 2. 下载指令数据（Instructions）

官方来源：`Zacks-Chen/CoIN` 的 `Instructions_Original`。

```bash
cd /path/to/ModalPrompt  # 改成你的仓库绝对路径
pip install -U "huggingface_hub[cli]"
export HF_ENDPOINT=https://hf-mirror.com

huggingface-cli download Zacks-Chen/CoIN \
  --repo-type dataset \
  --include "Instructions_Original/*/*.json" \
  --local-dir downloads/coin_instructions

mkdir -p instructions
rsync -av --delete \
  downloads/coin_instructions/Instructions_Original/ \
  instructions/
```

执行后应至少包含：

- `instructions/ScienceQA/{train.json,test.json}`
- `instructions/TextVQA/{train.json,val.json,test.json}`
- `instructions/ImageNet/{train.json,test.json}`
- `instructions/GQA/{train.json,test.json}`
- `instructions/VizWiz/{train.json,val.json,test.json}`
- `instructions/Grounding/{train.json,test.json}`
- `instructions/VQAv2/{train.json,val.json,test.json}`
- `instructions/OCRVQA/{train.json,test.json}`

## 2.1 下载基础模型（LLaVA + CLIP，训练/评测必需）

本仓库脚本默认读取：

- `models/llava_v1.5-7b`
- `models/clip-vit-large-patch14-336`

在服务器执行：

```bash
cd /path/to/ModalPrompt  # 改成你的仓库绝对路径
mkdir -p models
pip install -U "huggingface_hub[cli]"
export HF_ENDPOINT=https://hf-mirror.com

# LLaVA v1.5 7B（脚本里 --model_name_or_path 和 --model-base 使用）
huggingface-cli download liuhaotian/llava-v1.5-7b \
  --local-dir models/llava_v1.5-7b \
  --local-dir-use-symlinks False

# CLIP ViT-L/14-336（脚本里 --vision_tower 和 --text_tower 使用）
huggingface-cli download openai/clip-vit-large-patch14-336 \
  --local-dir models/clip-vit-large-patch14-336 \
  --local-dir-use-symlinks False
```

若希望长期生效（每次登录自动走镜像）：

```bash
echo 'export HF_ENDPOINT=https://hf-mirror.com' >> ~/.bashrc
source ~/.bashrc
```

快速校验关键文件是否存在：

```bash
cd /path/to/ModalPrompt  # 改成你的仓库绝对路径
test -f models/llava_v1.5-7b/config.json
test -f models/llava_v1.5-7b/mm_projector.bin
test -f models/clip-vit-large-patch14-336/config.json
```

---

## 3. 图像数据下载（按 CoIN/ModalPrompt 所需任务）

建议先安装工具：

```bash
sudo apt-get update
sudo apt-get install -y aria2 unzip p7zip-full jq rsync
```

### 3.1 可直接命令下载的数据

```bash
cd /path/to/ModalPrompt/downloads  # 改成你的仓库绝对路径

# COCO (VQAv2/Grounding 依赖)
aria2c -x 16 -s 16 http://images.cocodataset.org/zips/train2014.zip
aria2c -x 16 -s 16 http://images.cocodataset.org/zips/val2014.zip
aria2c -x 16 -s 16 http://images.cocodataset.org/zips/test2015.zip

# GQA
aria2c -x 16 -s 16 https://downloads.cs.stanford.edu/nlp/data/gqa/images.zip

# TextVQA
aria2c -x 16 -s 16 https://dl.fbaipublicfiles.com/textvqa/images/train_val_images.zip
aria2c -x 16 -s 16 https://dl.fbaipublicfiles.com/textvqa/images/test_images.zip

# VizWiz
aria2c -x 16 -s 16 https://vizwiz.cs.colorado.edu/VizWiz_final/images/train.zip
aria2c -x 16 -s 16 https://vizwiz.cs.colorado.edu/VizWiz_final/images/val.zip
aria2c -x 16 -s 16 https://vizwiz.cs.colorado.edu/VizWiz_final/images/test.zip

# RefCOCO / RefCOCO+ / RefCOCOg 标注（Grounding 依赖）
aria2c -x 16 -s 16 https://bvisionweb1.cs.unc.edu/licheng/referit/data/refcoco.zip
aria2c -x 16 -s 16 https://bvisionweb1.cs.unc.edu/licheng/referit/data/refcoco+.zip
aria2c -x 16 -s 16 https://bvisionweb1.cs.unc.edu/licheng/referit/data/refcocog.zip
```

解压并放到 `datasets/`：

```bash
cd /path/to/ModalPrompt  # 改成你的仓库绝对路径

unzip -q downloads/train2014.zip -d datasets/COCO2014
unzip -q downloads/val2014.zip   -d datasets/COCO2014
unzip -q downloads/test2015.zip  -d datasets/COCO2014

unzip -q downloads/images.zip -d datasets/GQA
unzip -q downloads/train_val_images.zip -d datasets/TextVQA
unzip -q downloads/test_images.zip      -d datasets/TextVQA

unzip -q downloads/train.zip -d datasets/VizWiz
unzip -q downloads/val.zip   -d datasets/VizWiz
unzip -q downloads/test.zip  -d datasets/VizWiz

unzip -q downloads/refcoco.zip  -d datasets
unzip -q downloads/refcoco+.zip -d datasets
unzip -q downloads/refcocog.zip -d datasets
```

### 3.2 需要账号/授权的数据

1. **ImageNet / ImageNet256**：需有合法访问权限（见第 5 节替代方案）。  
2. **OCR-VQA 图片**：官方给的是 Google Drive 文件夹链接。  
3. **ScienceQA 图片与元数据**：需要 `problems.json`、`pid_splits.json` 与图片目录。

> 这三类通常在内网环境中先由数据管理员下载后挂载到服务器，再按本仓库目录规范软链接/拷贝到 `datasets/`。

---

## 4. 评测额外依赖（除 instructions 之外）

根据仓库 `scripts/ModalPrompt/Eval/*.sh`，以下文件必须存在：

1. `datasets/ScienceQA/pid_splits.json`
2. `datasets/ScienceQA/problems.json`
3. `datasets/TextVQA/TextVQA_0.5.1_val.json`

如果缺失，评测会直接失败。

---

## 5. 用 ImageNet256 替代 ImageNet 的可执行方案

仓库默认读取 `instructions/ImageNet/{train.json,test.json}`，其中每条样本有 `image` 相对路径。  
最稳妥做法是：**按指令 JSON 中实际引用的文件名，从 ImageNet256 素材库拷贝到 `datasets/` 的对应相对路径**。

### 5.1 前提

- 你已在服务器上准备好 ImageNet256 原始目录（示例）：`/data/imagenet256`
- 其下包含大量图片文件（文件名与 ImageNet 原文件名一致）

### 5.2 执行映射拷贝

```bash
cd /path/to/ModalPrompt  # 改成你的仓库绝对路径

export IMAGENET256_ROOT=/data/imagenet256  # 改成你的 ImageNet256 根目录

python - <<'PY'
import json, os, shutil
from pathlib import Path

repo = Path(".").resolve()
ins_files = [
    repo / "instructions/ImageNet/train.json",
    repo / "instructions/ImageNet/test.json",
]
dst_root = repo / "datasets"
src_root = Path(os.environ["IMAGENET256_ROOT"]).resolve()

needed = set()
for fp in ins_files:
    data = json.loads(fp.read_text())
    for x in data:
        img = x.get("image")
        if img:
            needed.add(img)

# 建立 basename -> 全路径索引
index = {}
for p in src_root.rglob("*"):
    if p.is_file():
        index.setdefault(p.name, []).append(p)

missing = []
copied = 0
for rel in sorted(needed):
    rel_path = Path(rel)
    out = dst_root / rel_path
    out.parent.mkdir(parents=True, exist_ok=True)
    candidates = index.get(rel_path.name, [])
    if not candidates:
        missing.append(rel)
        continue
    # 若重名，优先选路径中包含同类目录名的候选；否则取第一个
    pick = None
    rel_parts = set(rel_path.parts)
    for c in candidates:
        if rel_parts & set(c.parts):
            pick = c
            break
    if pick is None:
        pick = candidates[0]
    shutil.copy2(pick, out)
    copied += 1

print(f"needed={len(needed)} copied={copied} missing={len(missing)}")
if missing:
    miss_fp = repo / "downloads/imagenet256_missing.txt"
    miss_fp.parent.mkdir(parents=True, exist_ok=True)
    miss_fp.write_text("\\n".join(missing))
    print(f"missing list -> {miss_fp}")
PY
```

### 5.3 脚本兼容性处理（可选）

若你的指令里仍引用 `ImageNet/...` 路径，而你希望实际目录名叫 `ImageNet256`，可加软链接：

```bash
cd /path/to/ModalPrompt/datasets  # 改成你的仓库绝对路径
# 如果 ImageNet 已存在为目录，先备份或删除，再创建软链接
if [ -e ImageNet ] && [ ! -L ImageNet ]; then mv ImageNet ImageNet.bak.$(date +%Y%m%d%H%M%S); fi
ln -sfn ImageNet256 ImageNet
```

---

## 6. 一键检查（训练前必须过）

```bash
cd /path/to/ModalPrompt  # 改成你的仓库绝对路径
python - <<'PY'
import json, os
from pathlib import Path

repo = Path(".").resolve()
must_files = [
    "instructions/ScienceQA/train.json",
    "instructions/TextVQA/train.json",
    "instructions/ImageNet/train.json",
    "instructions/GQA/train.json",
    "instructions/VizWiz/train.json",
    "instructions/Grounding/train.json",
    "instructions/VQAv2/train.json",
    "instructions/OCRVQA/train.json",
    "datasets/ScienceQA/pid_splits.json",
    "datasets/ScienceQA/problems.json",
    "datasets/TextVQA/TextVQA_0.5.1_val.json",
]

missing = [p for p in must_files if not (repo / p).exists()]
if missing:
    print("MISSING_FILES:")
    for x in missing:
        print(" -", x)
    raise SystemExit(1)

# 抽样检查图像可达性（每任务前 200 条）
tasks = ["ScienceQA","TextVQA","ImageNet","GQA","VizWiz","Grounding","VQAv2","OCRVQA"]
for t in tasks:
    fp = repo / f"instructions/{t}/train.json"
    arr = json.loads(fp.read_text())
    bad = 0
    for x in arr[:200]:
        img = x.get("image")
        if img and not (repo / "datasets" / img).exists():
            bad += 1
    print(f"{t}: sample_missing={bad}/200")
PY
```

---

## 7. 与本仓库脚本对应的最小可跑集合

如果你只想先验证链路（不跑全量）：

1. 先准备 `ScienceQA + TextVQA + ImageNet256(映射后)` 三个任务的 images + instructions  
2. 执行：

```bash
sh scripts/ModalPrompt/Train/1_Science.sh
sh scripts/ModalPrompt/Train/2_TextVQA.sh
sh scripts/ModalPrompt/Train/3_ImageNet.sh
```

3. 再执行单任务评测验证：

```bash
sh scripts/ModalPrompt/Eval/1_eval_sqa.sh Finetune checkpoints/ModalPrompt/ScienceQA/llava-1.5-7b 1 8
```
