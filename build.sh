#!/bin/bash

source ./image-configs/$1-$2.shvars
sh ./scripts/prep-userdata-$2-iso.sh

if [ $2 == "vmware" ]; then 
  packer build -on-error=ask -var username=${USERNAME} -var password=${PASSWORD} -var hostname=${HOSTNAME} -var-file=./image-configs/$1-$2.pkrvars.hcl -only vmware-iso.kali .
fi

if [ $2 == "virtualbox" ]; then 
  packer build -on-error=ask -var username=${USERNAME} -var password=${PASSWORD} -var hostname=${HOSTNAME} -var-file=./image-configs/$1-$2.pkrvars.hcl -only virtualbox-iso.kali .
fi

if [ $2 == "proxmox" ]; then
  packer build -var username=${USERNAME} -var password=${PASSWORD} -var hostname=${HOSTNAME} -var-file=./image-configs/$1-$2.pkrvars.hcl -only proxmox-iso.kali .
fi

if [ $2 == "vagrant" ]; then
  if [ ! -f "./output-vmware/packer_kali_vmware.box" ]; then
      packer build -on-error=ask -var username=${USERNAME} -var password=${PASSWORD} -var hostname=${HOSTNAME} -var-file=./image-configs/$1-$2.pkrvars.hcl -only vmware-iso.kali .
  fi
  ./update-version.sh
  source ./VERSION
  packer build -on-error=ask -var vagrant_version=${VERSION} -var-file=./image-configs/$1-$2.pkrvars.hcl -only=null.vagrant .
fi
