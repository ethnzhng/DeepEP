#!/usr/bin/env bash
set -e

sudo apt install -y libnccl2 libnccl-dev

# build & install NVSHMEM
cd ~
wget https://developer.nvidia.com/downloads/assets/secure/nvshmem/nvshmem_src_3.2.5-1.txz
tar -xvf nvshmem_src_3.2.5-1.txz
cd nvshmem_src

# apply DeekSeek patch
git apply ~/repos/DeepEP/third-party/nvshmem.patch

export FI_PROVIDER="efa"
export FI_EFA_USE_DEVICE_RDMA=1

export NVSHMEM_LIBFABRIC_PROVIDER="efa"
export NVSHMEM_BOOTSTRAP="MPI"

export CUDA_HOME=/usr/local/cuda
export LIBFABRIC_HOME=/opt/amazon/efa
export GDRCOPY_HOME=/usr/lib/x86_64-linux-gnu
export NCCL_HOME=/opt/aws-ofi-nccl
export MPI_HOME=/opt/amazon/openmpi

cmake -S . -B build/ -DCMAKE_INSTALL_PREFIX=/usr/local/nvshmem \
    -DCUDA_HOME=$CUDA_HOME \
    -DLIBFABRIC_HOME=$LIBFABRIC_HOME \
    -DGDRCOPY_HOME=$GDRCOPY_HOME \
    -DNCCL_HOME=$NCCL_HOME \
    -DMPI_HOME=$MPI_HOME \
    -DNVSHMEM_SHMEM_SUPPORT=OFF \
    -DNVSHMEM_UCX_SUPPORT=OFF \
    -DNVSHMEM_USE_NCCL=ON \
    -DNVSHMEM_MPI_SUPPORT=ON \
    -DNVSHMEM_IBGDA_SUPPORT=ON \
    -DNVSHMEM_IBRC_SUPPORT=OFF \
    -DNVSHMEM_PMIX_SUPPORT=OFF \
    -DNVSHMEM_TIMEOUT_DEVICE_POLLING=OFF \
    -DNVSHMEM_USE_GDRCOPY=ON \
    -DNVSHMEM_LIBFABRIC_SUPPORT=ON
    
cd build
make -j$(nproc)
sudo make install

export NVSHMEM_DIR=/usr/local/nvshmem  # Use for DeepEP installation
export LD_LIBRARY_PATH="${NVSHMEM_DIR}/lib:$LD_LIBRARY_PATH"
export PATH="${NVSHMEM_DIR}/bin:$PATH"

nvshmem-info -a # Should display details of nvshmem


# install deep_ep python
cd ~/repos/DeepEP
sudo pip install --upgrade ninja mpi4py
sudo pip install torch --index-url https://download.pytorch.org/whl/cu121
sudo -E python3 setup.py install
