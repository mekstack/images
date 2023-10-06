#!/bin/bash
#Make more space in tmp
sudo mount -o remount,size=10G /tmp/

python3 -m venv .venv
source .venv/bin/activate

pip install diskimage-builder

function copy_to_builder_element(){
    cp -r $1 .venv/lib64/$(ls .venv/lib64 | grep python )/site-packages/diskimage_builder/elements/$2 || 
        cp -r $1 .venv/lib/$(ls .venv/lib | grep python )/site-packages/diskimage_builder/elements/$2
}

#static installs - custom docker network; time zone; bash_rc; dot_files;
copy_to_builder_element static/ install-static/

#Btrfs convertion
export DIB_BLOCK_DEVICE_CONFIG=$(cat block_device.yml)

#Install packages specified in package-installs
copy_to_builder_element package-installs.yaml package-installs

#Make image use openstack userdatas
export DIB_CLOUD_INIT_DATASOURCES="Ec2, ConfigDrive, OpenStack"

#Configure admin user 
export DIB_DEV_USER_USERNAME=cloud
export DIB_DEV_USER_SHELL=/bin/fish
export DIB_DEV_USER_PWDLESS_SUDO=yes


#fix debian-specific problems
export DIB_DISTRIBUTION_MIRROR="https://mirror.yandex.ru/debian/"
export DIB_RELEASE=stable
export DIB_APT_KEYRING=/usr/share/keyrings/debian-archive-keyring.gpg
export DIB_DEBOOTSTRAP_EXTRA_ARGS="--include=gnupg,coreutils,btrfs-progs --merged-usr" #THIS CAN'T BE FUCKING DONE ANOTHER WAY I HATE DEBIAN I HATE DEBIAN

disk-image-create --no-tmpfs \
       cleanup-kernel-initrd \
        -o "mekstack_debian" \
         vm block-device-mbr \
              debian-systemd \
              install-static \
              openssh-server \
                        base \
                     devuser \
                  cloud-init \
      cloud-init-datasources \
         dhcp-all-interfaces 

