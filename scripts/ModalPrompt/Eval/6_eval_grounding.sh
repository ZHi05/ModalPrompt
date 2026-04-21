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
GPUS=${GPUS:-0}

MODEL_BASE_ARGS=""
if [ "${MODEL_BASE+x}" = "x" ]; then
    if [ -n "$MODEL_BASE" ]; then
        MODEL_BASE_ARGS="--model-base $MODEL_BASE"
    fi
else
    MODEL_BASE_ARGS="--model-base models/llava_v1.5-7b"
fi

RESULT_DIR=${RESULT_DIR:-./results/ModalPrompt/Grounding}
mkdir -p "$RESULT_DIR/$STAGE"

MERGE_FILE="$RESULT_DIR/$STAGE/merge.jsonl"
ANALYSIS_FILE="$RESULT_DIR/$STAGE/Result.text"
OLD_IFS=$IFS
IFS=','
set -- $GPUS
IFS=$OLD_IFS
CHUNKS=$#
if [ "$CHUNKS" -lt 1 ]; then
    echo "GPUS 参数无效: $GPUS"
    exit 1
fi

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
    python -m llava.eval.ModalPrompt.eval_grounding \
        --test-file instructions/Grounding/test.json \
        --result-file "$MERGE_FILE" \
        --output-dir "$RESULT_DIR/$STAGE"
}

run_inference() {
    OLD_IFS=$IFS
    IFS=','
    set -- $GPUS
    IFS=$OLD_IFS
    IDX=0
    for GPU_ID in "$@"; do
        CUDA_VISIBLE_DEVICES="$GPU_ID" python -m llava.eval.ModalPrompt.model_vqa_cc_instruction \
            --model-path "$MODEL_PATH" \
            $MODEL_BASE_ARGS \
            --question-file instructions/Grounding/test.json \
            --image-folder datasets/ \
            --text-tower models/clip-vit-large-patch14-336 \
            --prefix-len 10 \
            --cur-task "$CUR_TASK" \
            --num-task "$NUM_TASKS" \
            --answers-file "$RESULT_DIR/$STAGE/${CHUNKS}_${IDX}.jsonl" \
            --num-chunks "$CHUNKS" \
            --chunk-idx "$IDX" \
            --temperature 0 \
            --conv-mode vicuna_v1 &
        IDX=$((IDX + 1))
    done
    wait
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

run_inference

rebuild_merge_if_needed
run_analysis
