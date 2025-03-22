#!/usr/bin/env bash
set -e

# mount host nvidia drivers
docker run -it \
    --runtime=nvidia \
    --gpus all \
    --shm-size 20gb \
    -v /usr/src:/usr/src \
    -v ~/repos/DeepEP:/ws/DeepEP \
    -v ~/gdrcopy-2.4.4:/ws/gdrcopy-2.4.4 \
    --workdir /ws/DeepEP \
    --entrypoint /bin/bash \
    --name deepep \
    nvidia/cuda:12.2.2-devel-ubuntu22.04
