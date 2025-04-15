#!/usr/bin/env bash

# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/efa-start-nccl.html#nccl-start-base-test

# pure internode
/opt/amazon/openmpi/bin/mpirun \
    -x FI_EFA_USE_DEVICE_RDMA=1 \
    -x LD_LIBRARY_PATH=/opt/nccl/build/lib:/usr/local/cuda/lib64:/opt/amazon/efa/lib:/opt/amazon/openmpi/lib:/opt/amazon/ofi-nccl/lib:$LD_LIBRARY_PATH \
    -x NCCL_DEBUG=INFO \
    --hostfile hostfile \
    -tag-output \
    --map-by ppr:1:node \
    -n 2 \
    --mca pml ^cm \
    --mca btl tcp,self \
    --mca btl_tcp_if_exclude lo,docker0 \
    --bind-to none \
    $HOME/nccl-tests/build/all_reduce_perf \
        --minbytes 8M \
        --maxbytes 1G\
        --stepfactor 2 \
        --ngpus 1 \
        --check 1 \
        --warmup_iters 5 \
        --iters 18 \
        --average 1

# /opt/amazon/openmpi/bin/mpirun \
#     -x FI_EFA_USE_DEVICE_RDMA=1 \
#     -x LD_LIBRARY_PATH=/opt/nccl/build/lib:/usr/local/cuda/lib64:/opt/amazon/efa/lib:/opt/amazon/openmpi/lib:/opt/amazon/ofi-nccl/lib:$LD_LIBRARY_PATH \
#     -x NCCL_DEBUG=INFO \
#     --hostfile hostfile \
#     -tag-output \
#     -n 16 -N 8 \
#     --mca pml ^cm \
#     --mca btl tcp,self \
#     --mca btl_tcp_if_exclude lo,docker0 \
#     --bind-to none \
#     $HOME/nccl-tests/build/all_reduce_perf \
#         --minbytes 8M \
#         --maxbytes 1G\
#         --stepfactor 2 \
#         --ngpus 1 \
#         --check 1 \
#         --warmup_iters 5 \
#         --iters 18 \
#         --average 1
