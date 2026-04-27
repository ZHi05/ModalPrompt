################## VICUNA ##################
PROMPT_VERSION=v1
MODEL_VERSION="vicuna-7b-v1.5"
################## VICUNA ##################


################## LLaMA-2 ##################
# PROMPT_VERSION="llava_llama_2"
# MODEL_VERSION="Llama-2-7b-chat-hf"
################## LLaMA-2 ##################

# ===== Server tuning knobs (modify for your machine) =====
GPUS=${GPUS:-0,1,2,3,4,5,6,7}
MASTER_PORT=${MASTER_PORT:-13200}
DS_CONFIG=${DS_CONFIG:-./scripts/zero2.json}
TB_LOG_DIR=${TB_LOG_DIR:-runs/ModalPrompt_TextOnly/GQA}
SEED=${SEED:-42}
NUM_WORKERS=${NUM_WORKERS:-16}
SAVE_TOTAL_LIMIT=${SAVE_TOTAL_LIMIT:-2}
RESUME_FROM_CHECKPOINT=${RESUME_FROM_CHECKPOINT:-}
RESUME_ARGS=""
if [ -n "$RESUME_FROM_CHECKPOINT" ]; then
    RESUME_ARGS="--resume_from_checkpoint $RESUME_FROM_CHECKPOINT"
fi

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "${SCRIPT_DIR}/../../deepspeed_launch.sh"
DS_LAUNCH_ARGS=$(build_deepspeed_launch_args "${GPUS}" "${MASTER_PORT}")

deepspeed ${DS_LAUNCH_ARGS} llava/train/train_mem.py \
    --deepspeed ${DS_CONFIG} \
    --lora_enable False --mm_projector_lr 2e-5 --pt_enable True \
    --model_name_or_path models/llava_v1.5-7b \
    --previous_task_model_path checkpoints/ModalPrompt_TextOnly/ImageNet/llava-1.5-7b \
    --version $PROMPT_VERSION \
    --data_path instructions/GQA/train.json \
    --image_folder datasets \
    --vision_tower models/clip-vit-large-patch14-336 \
    --text_tower models/clip-vit-large-patch14-336 \
    --pretrain_mm_mlp_adapter models/llava_v1.5-7b/mm_projector.bin \
    --mm_projector_type mlp2x_gelu \
    --mm_vision_select_layer -2 \
    --mm_text_select_layer -1 \
    --prefix_len 10 \
    --cur_task 4 \
    --num_tasks 8 \
    --guidance_mode text \
    --mm_use_im_start_end False \
    --mm_use_im_patch_token False \
    --image_aspect_ratio pad \
    --group_by_modality_length True \
    --bf16 True \
    --output_dir checkpoints/ModalPrompt_TextOnly/GQA/llava-1.5-7b \
    --num_train_epochs 4 \
    --per_device_train_batch_size 24 \
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
