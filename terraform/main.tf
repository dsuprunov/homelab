#
# vm
#
resource "proxmox_vm_qemu" "vm" {
  for_each = var.vm

  # Identity & source
  vmid        = each.value.vmid
  name        = each.key
  tags        = join(";", sort(each.value.tags))
  target_node = each.value.target_node
  clone       = each.value.template
  full_clone  = true
  onboot      = each.value.onboot
  vm_state    = each.value.state

  # Hardware
  bios    = "ovmf"
  machine = "q35"
  cpu {
    cores   = each.value.cores
    sockets = 1
    type    = "host"
    numa    = false
  }
  memory  = each.value.memory
  balloon = coalesce(each.value.balloon, each.value.memory)
  boot    = "order=scsi0"
  scsihw  = "virtio-scsi-single"
  serial {
    id   = 0
    type = "socket"
  }
  vga {
    type = "serial0"
  }
  rng {
    source = "/dev/urandom"
  }
  agent = 1

  # Network
  network {
    id       = 0
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = true
  }

  # Disk
  disks {
    scsi {
      scsi0 {
        disk {
          storage    = "local-lvm"
          size       = each.value.disk
          emulatessd = true
          iothread   = true
          discard    = true
        }
      }
      dynamic "scsi1" {
        for_each = try(each.value.attachments.scsi1, null) == null ? [] : [each.value.attachments.scsi1]
        content {
          dynamic "disk" {
            for_each = try(scsi1.value.disk, null) == null ? [] : [scsi1.value.disk]
            content {
              storage    = disk.value.storage
              size       = disk.value.size
              iothread   = disk.value.iothread
              discard    = disk.value.discard
              emulatessd = disk.value.emulatessd
            }
          }
          dynamic "passthrough" {
            for_each = try(scsi1.value.passthrough, null) == null ? [] : [scsi1.value.passthrough]
            content {
              file       = passthrough.value.file
              iothread   = passthrough.value.iothread
              discard    = passthrough.value.discard
              emulatessd = passthrough.value.emulatessd
            }
          }
        }
      }
      scsi2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  # Cloud-Init
  ipconfig0  = each.value.ipconfig
  nameserver = try(each.value.nameserver, null)
  skip_ipv6  = true
  ciuser     = each.value.user
  sshkeys    = each.value.ssh_key
}