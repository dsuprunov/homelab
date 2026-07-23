locals {
  debian_13_artifact_name = "debian-13.qcow2"
  debian_13_output_dir    = "${var.artifact_dir}/debian-13/${var.image_version}"
  debian_13_source_url    = "https://cloud.debian.org/images/cloud/trixie/20260712-2537/debian-13-genericcloud-amd64-20260712-2537.qcow2"
  debian_13_ssh_username  = "debian"
}

source "qemu" "debian_13" {
  accelerator      = "tcg"
  boot_wait        = "5s"
  cd_files         = ["${var.cloud_init_dir}/user-data", "${var.cloud_init_dir}/meta-data"]
  cd_label         = "cidata"
  cpus             = 1
  disk_image       = true
  disk_size        = "8G"
  format           = "qcow2"
  headless         = true
  iso_checksum     = "sha512:7ae53e9dbee282bfc16f289dec483dde3a8598769c38a267948310f7a2a52c662620198603bc52c142627efba379863d16079698a10b34102d55bcedd40e8d32"
  iso_url          = local.debian_13_source_url
  memory           = 1024
  output_directory = local.debian_13_output_dir
  qemu_binary      = "/usr/bin/qemu-system-x86_64"
  shutdown_command = "sudo passwd --lock ${local.debian_13_ssh_username} && sudo cloud-init clean --logs --seed && sudo shutdown -P now"
  ssh_password     = var.ssh_password
  ssh_timeout      = "35m"
  ssh_username     = local.debian_13_ssh_username
  vm_name          = local.debian_13_artifact_name
}

build {
  sources = ["source.qemu.debian_13"]

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
