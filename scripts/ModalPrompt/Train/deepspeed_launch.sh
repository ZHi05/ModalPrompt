#!/bin/bash

# Build deepspeed launch args for single-node or multi-node.
# Env vars:
#   NNODES: total node count, default 1
#   NODE_RANK: current node rank [0..NNODES-1], default 0
#   MASTER_ADDR: rank0 node address, default 127.0.0.1
#   NUM_GPUS_PER_NODE: gpu count per node, default derived from GPUS list length
build_deepspeed_launch_args() {
    local gpus="$1"
    local master_port="$2"

    local nnodes="${NNODES:-1}"
    local node_rank="${NODE_RANK:-0}"
    local master_addr="${MASTER_ADDR:-127.0.0.1}"
    local num_gpus_per_node="${NUM_GPUS_PER_NODE:-$(echo "$gpus" | awk -F',' '{print NF}')}"

    if [ "${nnodes}" -gt 1 ]; then
        echo "--num_nodes ${nnodes} --num_gpus ${num_gpus_per_node} --node_rank ${node_rank} --master_addr ${master_addr} --master_port ${master_port}"
    else
        echo "--include localhost:${gpus} --master_port ${master_port}"
    fi
}
