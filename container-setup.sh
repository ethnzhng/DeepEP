#!/usr/bin/env bash
set -e

apt update
apt install -y dkms
apt install --fix-broken -y
apt install -y libmlx5-1 librdmacm1 libibverbs1 rdma-core libibverbs-dev
apt install -y wget cmake git python3-pip

# install GDRCopy built on host in container
cd /ws/gdrcopy-2.4.4

pushd packages
dpkg -i gdrdrv-dkms_2.4.4_amd64.Ubuntu22_04.deb \
        libgdrapi_2.4.4_amd64.Ubuntu22_04.deb \
        gdrcopy-tests_2.4.4_amd64.Ubuntu22_04+cuda12.2.deb \
        gdrcopy_2.4.4_amd64.Ubuntu22_04.deb
popd


# build & install NVSHMEM
cd /ws
wget https://developer.nvidia.com/downloads/assets/secure/nvshmem/nvshmem_src_3.2.5-1.txz
tar -xvf nvshmem_src_3.2.5-1.txz
cd nvshmem_src

# apply DeekSeek patch
git apply /ws/DeepEP/third-party/nvshmem.patch

CUDA_HOME=/usr/local/cuda \
GDRCOPY_HOME=/usr/lib/x86_64-linux-gnu \
NVSHMEM_SHMEM_SUPPORT=0 \
NVSHMEM_UCX_SUPPORT=0 \
NVSHMEM_USE_NCCL=0 \
NVSHMEM_MPI_SUPPORT=0 \
NVSHMEM_IBGDA_SUPPORT=1 \
NVSHMEM_IBRC_SUPPORT=0 \
NVSHMEM_PMIX_SUPPORT=0 \
NVSHMEM_TIMEOUT_DEVICE_POLLING=0 \
NVSHMEM_USE_GDRCOPY=1 \
cmake -S . -B build/ -DCMAKE_INSTALL_PREFIX=/usr/local/nvshmem \
    -DMLX5_lib=/usr/lib/x86_64-linux-gnu/libmlx5.so

cd build
make -j$(nproc)
make install

export NVSHMEM_DIR=/usr/local/nvshmem  # Use for DeepEP installation
export LD_LIBRARY_PATH="${NVSHMEM_DIR}/lib:$LD_LIBRARY_PATH"
export PATH="${NVSHMEM_DIR}/bin:$PATH"

nvshmem-info -a # Should display details of nvshmem


# install deep_ep python
cd /ws/DeepEP
python3 -m pip install --upgrade setuptools torch ninja numpy
python3 setup.py install
