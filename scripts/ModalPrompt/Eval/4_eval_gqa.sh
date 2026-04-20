#!/bin/bash

CHUNKS=1
IDX=0

STAGE=$1
MODELPATH=$2
CUR_TASK=$3
NUM_TASKS=$4

RESULT_DIR="./results/ModalPrompt/GQA"
if [ -z "${MODEL_BASE+x}" ]; then
    MODEL_BASE="models/llava_v1.5-7b"
fi
if [ -n "$MODEL_BASE" ]; then
    MODEL_BASE_ARGS="--model-base $MODEL_BASE"
else
    MODEL_BASE_ARGS=""
fi

CUDA_VISIBLE_DEVICES=0 python -m llava.eval.ModalPrompt.model_gqa \
    --model-path $MODELPATH \
    $MODEL_BASE_ARGS \
    --question-file instructions/GQA/test.json \
    --image-folder datasets/ \
    --text-tower models/clip-vit-large-patch14-336 \
    --prefix-len 10 \
    --cur-task $CUR_TASK \
    --num-task $NUM_TASKS \
    --answers-file $RESULT_DIR/$STAGE/${CHUNKS}_${IDX}.jsonl \
    --num-chunks $CHUNKS \
    --chunk-idx $IDX \
    --temperature 0 \
    --conv-mode vicuna_v1 &

wait

output_file=$RESULT_DIR/$STAGE/merge.jsonl

# Clear out the output file if it exists.
> "$output_file"

# Loop through the indices and concatenate each file.
for IDX in $(seq 0 $((CHUNKS-1))); do
    cat $RESULT_DIR/$STAGE/${CHUNKS}_${IDX}.jsonl >> "$output_file"
done

python scripts/convert_gqa_for_eval.py --src $output_file --dst $RESULT_DIR/$STAGE/testdev_balanced_predictions.json

python llava/eval/ModalPrompt/eval_gqa.py --tier testdev_balanced --path $RESULT_DIR/$STAGE --output-dir $RESULT_DIR/$STAGE 
