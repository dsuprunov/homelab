locals {
  talos_nodes = {
    "vm-k8s-control-01" = {
      vm_id  = 101
      cores  = 2
      memory = 4096

      disks = [
        { interface = "scsi0", size = 32 },
      ]
    }
    "vm-k8s-worker-01" = {
      vm_id  = 104
      cores  = 2
      memory = 6144

      disks = [
        { interface = "scsi0", size = 32 },
      ]
    }
    "vm-k8s-worker-02" = {
      vm_id  = 105
      cores  = 2
      memory = 6144

      disks = [
        { interface = "scsi0", size = 32 },
      ]
    }
    "vm-k8s-worker-03" = {
      vm_id  = 106
      cores  = 2
      memory = 6144

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
  scsi_hardware = "virtio-scsi-pci"
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

  rng {
    source = "/dev/urandom"
  }

  operating_system {
    type = "l26"
  }
}
