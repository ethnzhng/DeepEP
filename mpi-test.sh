#!/usr/bin/env bash
set -e

source envfile

LOG_NAME="q.log"

add_timestamp() {
    while IFS= read -r line; do
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] $line"
    done
}

HOSTFILE=hostfile

CUDA_LAUNCH_BLOCKING=1

NCCL_DEBUG=INFO
NVSHMEM_DEBUG=INFO
FI_LOG_LEVEL=warn

time /opt/amazon/openmpi/bin/mpirun \
    -n 16 \
    -tag-output \
    --map-by ppr:8:node \
    --hostfile ${HOSTFILE} \
    -x LD_LIBRARY_PATH=/opt/nccl/build/lib:/usr/local/cuda/lib64:/opt/amazon/efa/lib:/opt/amazon/openmpi/lib:/opt/amazon/ofi-nccl/lib:$LD_LIBRARY_PATH \
    -x PYTHONPATH=$(pwd):$PYTHONPATH \
    -x CUDA_LAUNCH_BLOCKING=${CUDA_LAUNCH_BLOCKING} \
    -x MASTER_ADDR=${MASTER_ADDR} \
    -x MASTER_PORT=${MASTER_PORT} \
    --mca pml ^cm \
    --mca btl tcp,self \
    --mca btl_tcp_if_exclude lo,docker0 \
    --bind-to none \
    -x NVSHMEM_DEBUG=${NVSHMEM_DEBUG} \
    python3 tests/test_internode.py \
    2>&1 | add_timestamp | tee $LOG_NAME

    # -x NCCL_DEBUG=${NCCL_DEBUG} \
    # -x FI_LOG_LEVEL=${FI_LOG_LEVEL} \
