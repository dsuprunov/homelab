locals {
  talos_nodes = {
    "talos-01" = {
      vm_id  = 101
      cores  = 2
      memory = 4096

      disks = [
        { interface = "scsi0", size = 32 },
      ]
    }
    "talos-02" = {
      vm_id  = 102
      cores  = 2
      memory = 4096

      disks = [
        { interface = "scsi0", size = 32 },
      ]
    }
    "talos-03" = {
      vm_id  = 103
      cores  = 2
      memory = 4096

      disks = [
        { interface = "scsi0", size = 32 },
      ]
    }
  }
}

resource "proxmox_virtual_environment_vm" "talos" {
  for_each = local.talos_nodes

  name      = each.key
  node_name = "pve-01"
  vm_id     = each.value.vm_id

  bios          = "ovmf"
  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  boot_order    = ["scsi2", "scsi0"]

  efi_disk {
    datastore_id = "local-lvm"
    file_format  = "raw"
    type         = "4m"
  }

  agent {
    enabled = true
  }

  cpu {
    cores   = each.value.cores
    sockets = 1
    type    = "host"
    numa    = false
  }

  memory {
    dedicated = each.value.memory
    floating  = 0
  }

  dynamic "disk" {
    for_each = { for disk_config in each.value.disks : disk_config.interface => disk_config }
    iterator = disk_config

    content {
      datastore_id = "local-lvm"

      interface = disk_config.key
      size      = disk_config.value.size

      aio      = "io_uring"
      cache    = "none"
      discard  = "on"
      iothread = true
      ssd      = true
    }
  }

  cdrom {
    file_id   = "local:iso/nocloud-amd64.iso"
    interface = "scsi2"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  serial_device {
    device = "socket"
  }

  vga {
    type = "serial0"
  }

  rng {
    source = "/dev/urandom"
  }

  operating_system {
    type = "l26"
  }
}
