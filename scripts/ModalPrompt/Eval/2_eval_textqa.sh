#!/bin/bash
set -e

if [ "$#" -ne 4 ]; then
  echo "Usage: sh scripts/ModalPrompt/Eval/2_eval_textqa.sh <STAGE> <MODEL_PATH> <CUR_TASK> <NUM_TASKS>"
  exit 1
fi

CHUNKS=1
IDX=0

STAGE=$1
MODELPATH=$2
CUR_TASK=$3
NUM_TASKS=$4

RESULT_DIR=${RESULT_DIR:-./results/ModalPrompt/TextVQA}

# MODEL_BASE 参数语义：
# - 未设置 MODEL_BASE：默认使用 CL base
# - 显式设置 MODEL_BASE=""：不传 --model-base（用于 zeroshot）
MODEL_BASE_ARGS=""
if [ -z "${MODEL_BASE+x}" ]; then
    MODEL_BASE="models/llava_v1.5-7b"
fi
if [ -n "$MODEL_BASE" ]; then
    MODEL_BASE_ARGS="--model-base $MODEL_BASE"
fi

mkdir -p "$RESULT_DIR/$STAGE"

MERGE_FILE="$RESULT_DIR/$STAGE/merge.jsonl"
ANALYSIS_FILE="$RESULT_DIR/$STAGE/Result.text"

has_chunks() {
    set -- "$RESULT_DIR/$STAGE"/*_*.jsonl
    [ -e "$1" ]
}

rebuild_merge_if_needed() {
    if has_chunks; then
        cat "$RESULT_DIR/$STAGE"/*_*.jsonl > "$MERGE_FILE"
    fi
}

run_analysis() {
    python -m llava.eval.ModalPrompt.eval_textvqa \
        --annotation-file datasets/TextVQA/TextVQA_0.5.1_val.json \
        --result-file "$MERGE_FILE" \
        --output-dir "$RESULT_DIR/$STAGE"
}

if [ -f "$ANALYSIS_FILE" ]; then
    echo "已存在输出: $ANALYSIS_FILE"
    exit 0
fi

if [ -f "$MERGE_FILE" ] || has_chunks; then
    echo "检测到已有推理输出，跳过推理，仅执行结果分析..."
    rebuild_merge_if_needed
    run_analysis
    exit 0
fi

CUDA_VISIBLE_DEVICES=0 python -m llava.eval.ModalPrompt.model_text_vqa \
    --model-path "$MODELPATH" \
    $MODEL_BASE_ARGS \
    --question-file instructions/TextVQA/val.json \
    --image-folder datasets/ \
    --text-tower models/clip-vit-large-patch14-336 \
    --prefix-len 10 \
    --cur-task "$CUR_TASK" \
    --num-task "$NUM_TASKS" \
    --answers-file "$RESULT_DIR/$STAGE/${CHUNKS}_${IDX}.jsonl" \
    --num-chunks "$CHUNKS" \
    --chunk-idx "$IDX" \
    --temperature 0 \
    --conv-mode vicuna_v1

rebuild_merge_if_needed
run_analysis
