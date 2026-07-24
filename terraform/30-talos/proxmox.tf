resource "proxmox_virtual_environment_vm" "talos" {
  for_each = local.nodes

  name      = each.key
  node_name = each.value.proxmox_node
  vm_id     = each.value.vm_id

  bios          = "ovmf"
  machine       = "q35"
  scsi_hardware = "virtio-scsi-pci"
  boot_order    = ["scsi0", "scsi2"]

  efi_disk {
    datastore_id = "local-lvm"
    file_format  = "raw"
    type         = "4m"
  }

  agent {
    enabled = true
    timeout = "15m"
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

      aio     = "io_uring"
      cache   = "none"
      discard = "on"
      ssd     = true
    }
  }

  cdrom {
    file_id   = local.cluster.iso_file_id
    interface = "scsi2"
  }

  network_device {
    bridge = each.value.network_interface.bridge
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
