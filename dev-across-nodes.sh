#!/usr/bin/env bash
set -e

# Run this on master node to sync workdir and build on other node
REBUILD_CSRC=$1

HOSTFILE="hostfile"
WORKDIR="/home/ubuntu/repos/DeepEP/"

# Read the hostfile and extract the hostnames
HOSTS=($(awk '{print $1}' "$HOSTFILE"))

# Check if we have at least two hosts
if [ ${#HOSTS[@]} -lt 2 ]; then
    echo "Error: Not enough hosts in the hostfile"
    exit 1
fi

SOURCE_HOST="${HOSTS[0]}"
TARGET_HOST="${HOSTS[1]}"
USER="ubuntu"

echo "Syncing $WORKDIR from $SOURCE_HOST to $TARGET_HOST..."
rsync \
    -a \
    --progress \
    --exclude=".git" \
    --filter=":- .gitignore" \
    -e ssh \
    $WORKDIR $USER@$TARGET_HOST:$WORKDIR
echo "Workdirs synced"

if [ -n $REBUILD_CSRC ]; then
    echo "Rebuilding DeepEP on both nodes"
    set -x
    mpirun \
        -np 2 \
        -hostfile ${HOSTFILE} \
        -map-by ppr:1:node \
        --mca pml ^cm \
        --mca btl tcp,self \
        --mca btl_tcp_if_exclude lo,docker0 \
        --bind-to none \
        bash build-deepep-dev.sh
else
    echo "Skipping rebuild cpp/cuda"
fi
