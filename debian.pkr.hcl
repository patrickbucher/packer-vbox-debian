packer {
    required_plugins {
        virtualbox = {
            version = "1.0.5"
            source = "github.com/hashicorp/virtualbox"
        }
    }
}

variable "iso_url" {
    type = string
    description = "The URL for the Ubuntu ISO image, to be found at https://www.debian.org/download"
}

variable "iso_checksum" {
    type = string
    description = "The checksum of the ISO image (see variable 'iso_url') with a prefix like sha256: or md5:"
}

variable "cpus" {
    type = number
    description = "The number of CPU cores"
}

variable "disk_size" {
    type = number 
    description = "The disk size in megabytes"
}

variable "memory" {
    type = number
    description = "The memory size in megabytes"
}

variable "codename" {
    type = string
    description = "A name suffix to be used for the output in the ./images/ folder"
}

variable "additional_packages" {
    type = list(string)
    description = "A list of additional packages to be installed"
    default = []
}

source "virtualbox-iso" "debian" {
    boot_wait = "10s"
    boot_keygroup_interval = "500ms"
    boot_command = [
        "<esc><wait>",
        "auto interface=enp0s8 url=http://{{.HTTPIP}}:{{.HTTPPort}}/preseed.cfg",
        "<wait><enter>",
    ]
    guest_os_type = "Debian_64"
    iso_url = var.iso_url
    iso_checksum = var.iso_checksum
    iso_interface = "sata"
    http_directory = "http"
    cpus = var.cpus
    disk_size = "${var.disk_size}"
    memory = var.memory
    gfx_vram_size = 128
    gfx_efi_resolution = "1920x1080"
    gfx_controller = "vboxsvga"
    gfx_accelerate_3d = true
    ssh_username = "packer"
    ssh_password = "packer"
    ssh_timeout = "15m"
    shutdown_command = "echo -n 'packer' | sudo -S poweroff"
    headless = false
    vboxmanage = [
        ["modifyvm", "{{.Name}}", "--nic2", "hostonly", "--hostonlyadapter2", "VirtualBox Host-Only Ethernet Adapter"],
    ]
    vm_name = "debian-${var.codename}"
    output_directory = "./images/debian-${var.codename}"
    keep_registered = true
    format = "ova"
}

local "packages" {
    expression = join(" ", var.additional_packages)
}

build {
    sources = ["sources.virtualbox-iso.debian"]
    provisioner "shell" {
        execute_command = "echo -n 'packer' | {{.Vars}} sudo -E -S bash '{{.Path}}'"
        inline = ["apt update -y", "apt install -y ${local.packages}"]
    }
}