#!/bin/bash
set -e

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <stage> <model_path> <cur_task> <num_tasks>"
    exit 1
fi

CHUNKS=1
IDX=0

STAGE=$1
MODEL_PATH=$2
CUR_TASK=$3
NUM_TASKS=$4

MODEL_BASE_ARGS=""
if [ "${MODEL_BASE+x}" = "x" ]; then
    if [ -n "$MODEL_BASE" ]; then
        MODEL_BASE_ARGS="--model-base $MODEL_BASE"
    fi
else
    MODEL_BASE_ARGS="--model-base models/llava_v1.5-7b"
fi

RESULT_DIR=${RESULT_DIR:-./results/ModalPrompt/VizWiz}
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
    python scripts/convert_vizwiz_for_submission.py \
        --annotation-file instructions/VizWiz/val.json \
        --result-file "$MERGE_FILE" \
        --result-upload-file "$RESULT_DIR/$STAGE/upload.json"
    python -m llava.eval.ModalPrompt.eval_vizwiz \
        --annotation-file instructions/VizWiz/val.json \
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

CUDA_VISIBLE_DEVICES=0 python -m llava.eval.ModalPrompt.model_vizwiz \
    --model-path "$MODEL_PATH" \
    $MODEL_BASE_ARGS \
    --question-file instructions/VizWiz/val.json \
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
