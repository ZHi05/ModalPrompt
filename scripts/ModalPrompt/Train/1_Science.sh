################## VICUNA ##################
PROMPT_VERSION=v1
MODEL_VERSION="vicuna-7b-v1.5"
################## VICUNA ##################


################## LLaMA-2 ##################
# PROMPT_VERSION="llava_llama_2"
# MODEL_VERSION="Llama-2-7b-chat-hf"
################## LLaMA-2 ##################

# ===== Server tuning knobs (modify for your machine) =====
# GPUS: comma-separated GPU ids, e.g. "0" (single card) or "0,1,2,3" (multi-card)
# MASTER_PORT: deepspeed communication port (change if port conflict)
# DS_CONFIG: deepspeed strategy; H20 96G recommended default is zero2
#            optional: ./scripts/zero3.json or ./scripts/zero3_offload.json for tighter memory
# TB_LOG_DIR: TensorBoard output directory
# SEED: random seed for reproducibility
# NUM_WORKERS: dataloader worker processes (128-core CPU can set larger values)
GPUS=${GPUS:-0,1,2,3,4,5,6,7}
MASTER_PORT=${MASTER_PORT:-13200}
DS_CONFIG=${DS_CONFIG:-./scripts/zero2.json}
TB_LOG_DIR=${TB_LOG_DIR:-runs/ModalPrompt/ScienceQA}
SEED=${SEED:-42}
NUM_WORKERS=${NUM_WORKERS:-16}
SAVE_TOTAL_LIMIT=${SAVE_TOTAL_LIMIT:-2}
RESUME_FROM_CHECKPOINT=${RESUME_FROM_CHECKPOINT:-}
RESUME_ARGS=""
if [ -n "$RESUME_FROM_CHECKPOINT" ]; then
    RESUME_ARGS="--resume_from_checkpoint $RESUME_FROM_CHECKPOINT"
fi

deepspeed --include localhost:${GPUS} --master_port ${MASTER_PORT} llava/train/train_mem.py \
    --deepspeed ${DS_CONFIG} \
    --lora_enable False --mm_projector_lr 2e-5 --pt_enable True \
    --model_name_or_path models/llava_v1.5-7b \
    --version $PROMPT_VERSION \
    --data_path instructions/ScienceQA/train.json \
    --image_folder datasets \
    --vision_tower models/clip-vit-large-patch14-336 \
    --text_tower models/clip-vit-large-patch14-336 \
    --pretrain_mm_mlp_adapter models/llava_v1.5-7b/mm_projector.bin \
    --mm_projector_type mlp2x_gelu \
    --mm_vision_select_layer -2 \
    --mm_text_select_layer -1 \
    --prefix_len 10 \
    --cur_task 1 \
    --num_tasks 8 \
    --mm_use_im_start_end False \
    --mm_use_im_patch_token False \
    --image_aspect_ratio pad \
    --group_by_modality_length True \
    --bf16 True \
    --output_dir checkpoints/ModalPrompt/ScienceQA/llava-1.5-7b \
    --num_train_epochs 4 \
    --per_device_train_batch_size 32 \
    --per_device_eval_batch_size 16 \
    --gradient_accumulation_steps 1 \
    --evaluation_strategy "no" \
    --save_strategy "epoch" \
    --save_total_limit ${SAVE_TOTAL_LIMIT} \
    --learning_rate 2e-4 \
    --weight_decay 0. \
    --warmup_ratio 0.03 \
    --lr_scheduler_type "cosine" \
    --logging_steps 1 \
    --tf32 True \
    --seed ${SEED} \
    --model_max_length 2048 \
    --gradient_checkpointing True \
    --dataloader_num_workers ${NUM_WORKERS} \
    --lazy_preprocess True \
    --report_to tensorboard \
    $RESUME_ARGS \
    --logging_dir ${TB_LOG_DIR}
