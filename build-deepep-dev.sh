#!/usr/bin/env bash
set -e

export NVSHMEM_DIR=/usr/local/nvshmem  # Use for DeepEP installation
export LD_LIBRARY_PATH="${NVSHMEM_DIR}/lib:$LD_LIBRARY_PATH"
export PATH="${NVSHMEM_DIR}/bin:$PATH"

export TORCH_USE_CUDA_DSA=1

cd ~/repos/DeepEP
sudo rm -f deep_ep_cpp.cpython-310-x86_64-linux-gnu.so
sudo -E python3 setup.py build
ln -s build/lib.linux-x86_64-cpython-310/deep_ep_cpp.cpython-310-x86_64-linux-gnu.so
