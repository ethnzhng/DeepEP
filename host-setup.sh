#!/usr/bin/env bash
set -e

# build and install GDRCopy on host 
cd ~
wget https://github.com/NVIDIA/gdrcopy/archive/refs/tags/v2.4.4.tar.gz
tar -xzvf v2.4.4.tar.gz
cd gdrcopy-2.4.4/
make -j$(nproc)
sudo make prefix=/opt/gdrcopy install

# Kernel module installation
pushd packages
CUDA=/usr/local/cuda ./build-deb-packages.sh
sudo dpkg -i gdrdrv-dkms_2.4.4_amd64.Ubuntu22_04.deb \
             libgdrapi_2.4.4_amd64.Ubuntu22_04.deb \
             gdrcopy-tests_2.4.4_amd64.Ubuntu22_04+cuda12.2.deb \
             gdrcopy_2.4.4_amd64.Ubuntu22_04.deb
popd

sudo ./insmod.sh  # Load kernel modules on the bare-metal system

gdrcopy_copybw  # Should show bandwidth test results

# Configure NVIDIA driver
if ! grep -q 'options nvidia NVreg_EnableStreamMemOPs=1 NVreg_RegistryDwords="PeerMappingOverride=1;"' /etc/modprobe.d/nvidia.conf; then
    echo 'options nvidia NVreg_EnableStreamMemOPs=1 NVreg_RegistryDwords="PeerMappingOverride=1;"' | sudo tee -a /etc/modprobe.d/nvidia.conf
fi
sudo update-initramfs -u
sudo reboot
