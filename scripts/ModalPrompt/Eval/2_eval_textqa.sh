#!/bin/bash
set -e

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <stage> <model_path> <cur_task> <num_tasks>"
    exit 1
fi

STAGE=$1
MODEL_PATH=$2
CUR_TASK=$3
NUM_TASKS=$4

if [ "${MODEL_BASE+x}" = "x" ]; then
    if [ -n "$MODEL_BASE" ]; then
        MODEL_BASE_ARGS=(--model-base "$MODEL_BASE")
    else
        MODEL_BASE_ARGS=()
    fi
else
    MODEL_BASE_ARGS=(--model-base "models/llava-v1.5-7b")
fi

RESULT_DIR=${RESULT_DIR:-./results/ModalPrompt/TextVQA}
mkdir -p "$RESULT_DIR/$STAGE"

CHUNKS_GLOB="$RESULT_DIR/$STAGE/*_*.jsonl"
MERGE_FILE="$RESULT_DIR/$STAGE/merge.jsonl"
ANALYSIS_FILE="$RESULT_DIR/$STAGE/Result.text"

rebuild_merge_if_needed() {
    if compgen -G "$CHUNKS_GLOB" > /dev/null; then
        cat $CHUNKS_GLOB > "$MERGE_FILE"
    fi
}

run_analysis() {
    python -m llava.eval.ModalPrompt.eval_textvqa \
        --annotation-file ./playground/data/eval/textvqa/llava_textvqa_val_v051_ocr.json \
        --result-file "$MERGE_FILE" \
        --output-dir "$RESULT_DIR/$STAGE"
}

if [ -f "$ANALYSIS_FILE" ]; then
    echo "已存在输出: $ANALYSIS_FILE"
    exit 0
fi

if [ -f "$MERGE_FILE" ] || compgen -G "$CHUNKS_GLOB" > /dev/null; then
    echo "检测到已有推理输出，跳过推理，仅执行结果分析..."
    rebuild_merge_if_needed
    run_analysis
    exit 0
fi

python -m llava.eval.ModalPrompt.model_vqa \
    --model-path "$MODEL_PATH" \
    "${MODEL_BASE_ARGS[@]}" \
    --question-file ./playground/data/eval/textvqa/llava_textvqa_val_v051.jsonl \
    --image-folder ./playground/data/eval/textvqa/train_images \
    --answers-file "$RESULT_DIR/$STAGE/${NUM_TASKS}_${CUR_TASK}.jsonl" \
    --temperature 0 \
    --conv-mode llava_v1 \
    --prefix_len 1 \
    --cur_task "$CUR_TASK" \
    --num_tasks "$NUM_TASKS"

rebuild_merge_if_needed
run_analysis
