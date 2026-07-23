locals {
  ubuntu_26_04_artifact_name = "ubuntu-26.04.qcow2"
  ubuntu_26_04_output_dir    = "${var.artifact_dir}/ubuntu-26.04/${var.image_version}"
  ubuntu_26_04_source_url    = "https://cloud-images.ubuntu.com/releases/resolute/release-20260720/ubuntu-26.04-server-cloudimg-amd64.img"
  ubuntu_26_04_ssh_username  = "ubuntu"
}

source "qemu" "ubuntu_26_04" {
  accelerator      = "tcg"
  boot_wait        = "5s"
  cd_files         = ["${var.cloud_init_dir}/user-data", "${var.cloud_init_dir}/meta-data"]
  cd_label         = "cidata"
  cpus             = 1
  disk_image       = true
  disk_size        = "8G"
  format           = "qcow2"
  headless         = true
  iso_checksum     = "sha256:117816726abbdefc5ef3e38902e81a76f1c76c3610e709999d0885f9d5d9b477"
  iso_url          = local.ubuntu_26_04_source_url
  memory           = 1024
  output_directory = local.ubuntu_26_04_output_dir
  qemu_binary      = "/usr/bin/qemu-system-x86_64"
  shutdown_command = "sudo passwd --lock ${local.ubuntu_26_04_ssh_username} && sudo cloud-init clean --logs --seed && sudo shutdown -P now"
  ssh_password     = var.ssh_password
  ssh_timeout      = "35m"
  ssh_username     = local.ubuntu_26_04_ssh_username
  vm_name          = local.ubuntu_26_04_artifact_name
}

build {
  sources = ["source.qemu.ubuntu_26_04"]

  provisioner "shell" {
    script = "${path.root}/scripts/wait-cloud-init.sh"
  }

  provisioner "shell" {
    script = "${path.root}/scripts/update-apt-package-index.sh"
  }

  provisioner "shell" {
    script = "${path.root}/scripts/install-qemu-guest-agent.sh"
  }

  provisioner "shell" {
    script = "${path.root}/scripts/configure-network-interface.sh"
  }
}
