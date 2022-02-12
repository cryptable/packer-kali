# VM Section
# ----------

variable "vm_name" {
  type    = string
  default = "kali"
}

variable "cpu" {
  type    = string
  default = "2"
}

variable "ram_size" {
  type    = string
  default = "2048"
}

variable "disk_size" {
  type    = string
  default = "20G"
}

variable "iso_checksum" {
  type    = string
  default = "31a21157378380e2c33b1cee39c303141b3f3c658fde457a545eb948094fab14"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

# This is different and configured in the variable templates
variable "eth_point" {
  type    = string
  default = "ens18"
}

# VMware Section
# --------------

variable "iso_url" {
  type    = string
  default = "https://cdimage.kali.org/kali-2021.4a/kali-linux-2021.4a-installer-amd64.iso"
}

variable "output_directory" {
  type    = string
  default = "output-vmware"
}

# Proxmox Section
# ---------------

variable "pve_username" {
  type    = string
  default = "root"
}

variable "pve_token" {
  type    = string
  default = "secret"
}

variable "pve_url" {
  type    = string
  default = "https://127.0.0.1:8006/api2/json"
}

variable "iso_file"  {
  type    = string
  default = "local:iso/kali-linux-2021.4a-installer-amd64.iso"
}

variable "vm_id" {
  type    = string
  default = "9000"
}

# Kali Section
# ------------

variable "username" {
  type    = string
  default = "kali"  
}

variable "password" {
  type    = string
  default = "Kali2021.4a"  
}

variable "hostname" {
  type    = string
  default = "kali"
}

variable "salt" {
  type    = string
  default = "0A1675EF"
}

# Vagrant Section
# ---------------

variable "vagrant_token" {
  type    = string
  default = "<Atlas token>"
}

variable "vagrant_version" {
  type    = string
  default = "0.0.0"
}

# VMWARE image section
# --------------------

source "vmware-iso" "kali" {
  boot_command         = [
    "<esc><wait>",
    "auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>",
    "locale=en_US <wait>",
    "keymap=us <wait>",
    "<enter><wait>",
  ]

  boot_wait            = "5s"
  communicator         = "ssh"
  cpus                 = "${var.cpu}"
  disk_size            = "${var.disk_size}"
  http_directory       = "./http/vmware/linux/kali/2021.4a"
  iso_checksum         = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  memory               = "${var.ram_size}"
  shutdown_command     = "echo '${var.password}' | sudo -S -E shutdown -P now"
  ssh_timeout          = "20m"
  ssh_username         = "${var.username}"
  ssh_password         = "${var.password}"
  vm_name              = "${var.vm_name}"
  guest_os_type        = "ubuntu-64"
  output_directory     = "${var.output_directory}"
  format = "ova"
}

# VirtualBox image section
# ------------------------

source "virtualbox-iso" "kali" {
  boot_command         = [
    "<esc><wait>",
    "auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>",
    "locale=en_US <wait>",
    "keymap=us <wait>",
    "<enter><wait>",
  ]

  boot_wait            = "5s"
  communicator         = "ssh"
  cpus                 = "${var.cpu}"
  disk_size            = "${var.disk_size}"
  http_directory       = "./http/virtualbox/linux/kali/2021.4a"
  iso_checksum         = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  memory               = "${var.ram_size}"
  shutdown_command     = "echo '${var.password}' | sudo -S -E shutdown -P now"
  ssh_timeout          = "20m"
  ssh_username         = "${var.username}"
  ssh_password         = "${var.password}"
  vm_name              = "${var.vm_name}"
  guest_os_type        = "Debian_64"
  output_directory     = "${var.output_directory}"
  format               = "ova"
  gfx_vram_size        = 128
}

# Proxmox image section
# ---------------------

source "proxmox-iso" "kali" {
  proxmox_url = "${var.pve_url}"
  username = "${var.pve_username}"
  token = "${var.pve_token}"
  node =  "pve"
  iso_checksum = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_file = "${var.iso_file}"
  insecure_skip_tls_verify = true
  boot_command         = [
    "<esc><wait>",
    "auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>",
    "locale=en_US <wait>",
    "keymap=us <wait>",
    "<enter><wait>"
  ]

  boot_wait            = "5s"
  communicator         = "ssh"
  cores                = "${var.cpu}"
  http_directory       = "./http/proxmox/linux/kali/2021.4a"
  memory               = "${var.ram_size}"
  ssh_timeout          = "30m"
  ssh_username         = "${var.username}"
  ssh_password         = "${var.password}"
  vm_name              = "${var.vm_name}"
  vm_id                = "${var.vm_id}"
  os        = "l26"
  network_adapters {
    model = "e1000"
    bridge = "vmbr0"
  }
  scsi_controller = "virtio-scsi-pci"
  disks {
    type = "scsi"
    disk_size  = "${var.disk_size}"
    storage_pool = "local-lvm"
    storage_pool_type = "lvm-thin"
    format = "raw"
  }
  template_name = "kali-template"
  template_description = "Kali Linux 2021.4a template to build Kali Linux"
}

source "null" "vagrant" {
  communicator = "none"
}

build {
  sources = [
    "source.vmware-iso.kali",
    "source.virtualbox-iso.kali",
    "source.proxmox-iso.kali",
    "source.null.vagrant"
  ]

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -S -E sh {{ .Path }}"
    scripts         = [
      "./scripts/update.sh", 
    ]
    only = [ 
      "vmware-iso.kali", 
      "proxmox-iso.kali" 
    ]
    expect_disconnect = true
  }
  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -S -E sh {{ .Path }}"
    scripts         = [
      "./scripts/virtualbox-guest.sh"
    ]
    only = [ 
      "virtualbox-iso.kali"
    ]
  }
  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -S -E sh {{ .Path }}"
    scripts         = [
      "./scripts/cleanup.sh",
    ]
    only = [ 
      "vmware-iso.kali", 
      "proxmox-iso.kali" 
    ]
  }
  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -S -E sh {{ .Path }}"
    scripts         = [
      "./scripts/harden.sh",
    ]
    only = [ 
      "vmware-iso.kali", 
      "proxmox-iso.kali" 
    ]
  }

  post-processors {  
    post-processor "artifice" {
      files = [
        "output-vmware/disk-s001.vmdk",
        "output-vmware/disk-s002.vmdk",
        "output-vmware/disk-s003.vmdk",
        "output-vmware/disk.vmdk",
        "output-vmware/kali-template.nvram",
        "output-vmware/kali-template.vmsd",
        "output-vmware/kali-template.vmx",
        "output-vmware/kali-template.vmxf"
      ]
      only = [ 
        "vmware-iso.kali", 
        "null.vagrant" 
      ]
    }
    post-processor "vagrant" {
      keep_input_artifact = true
      provider_override   = "vmware"
      output = "output-vmware/packer_kali_vmware.box"
      only = [ 
        "vmware-iso.kali", 
        "null.vagrant" 
      ]
    }
  }
  post-processors {  
    post-processor "artifice" {
      files = [
        "output-vmware/packer_ubuntu_vmware.box"
      ]
      only = [ 
        "null.vagrant"
      ]
    }
    post-processor "vagrant-cloud" {
      access_token = "${var.vagrant_token}"
      box_tag      = "cryptable/kali20214a"
      version      = "${var.vagrant_version}"
      version_description = "Empty Kali Linux 2021.4a"
      only = [ 
        "null.vagrant"
      ]
    }
  } 
}
