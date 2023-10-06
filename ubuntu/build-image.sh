#!/bin/bash

#Increase /tmp space so the image can be built
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

#Ssh server should not be that strict
export DIB_OPENSSH_SERVER_HARDENING=0

#Make image use openstack userdatas
export DIB_CLOUD_INIT_DATASOURCES="Ec2, ConfigDrive, OpenStack"

#Use Jammy jellyfish (22.04.3) release
export DIB_RELEASE="jammy"
#Configure admin user 
export DIB_DEV_USER_USERNAME=cloud
export DIB_DEV_USER_SHELL=/bin/fish
export DIB_DEV_USER_PWDLESS_SUDO=yes


disk-image-create --no-tmpfs \
       cleanup-kernel-initrd \
          -o mekstack_ubuntu \
         vm block-device-mbr \
                      ubuntu \
              install-static \
              openssh-server \
                        base \
                     devuser \
                  cloud-init \
      cloud-init-datasources \
         dhcp-all-interfaces 

