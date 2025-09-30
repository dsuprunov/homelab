#
# vm
#
resource "proxmox_vm_qemu" "vm" {
  for_each = var.vm

  # ---------- Identity & source ----------
  vmid        = each.value.vmid
  name        = each.key
  target_node = each.value.target_node
  clone       = each.value.template
  full_clone  = true

  # ---------- Lifecycle ----------
  vm_state = each.value.state
  onboot   = each.value.onboot
  # automatic_reboot = true

  # ---------- Hardware ----------
  bios    = "ovmf"
  memory  = each.value.memory
  balloon = each.value.memory

  agent = 1

  boot   = "order=scsi0"
  scsihw = "virtio-scsi-single"

  cpu {
    cores = each.value.cores
  }

  # ---------- Storage ----------
  disks {
    scsi {
      scsi0 {
        disk {
          storage    = "local-lvm"
          size       = each.value.disk
          iothread   = true
          discard    = true
          emulatessd = true
        }
      }
      scsi2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  # ---------- Network ----------
  network {
    id       = 0
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = true
  }

  # ---------- Console ----------
  serial {
    id = 0
  }

  # ---------- Cloud-Init ----------
  ciupgrade  = true
  nameserver = try(each.value.nameserver, null)
  ipconfig0  = each.value.ipconfig
  skip_ipv6  = true
  ciuser     = each.value.user
  sshkeys    = each.value.ssh_key

  # ---------- Misc ----------
  tags = length(try(each.value.tags, [])) > 0 ? join(";", sort(each.value.tags)) : null

  lifecycle {
    ignore_changes = [tags]
  }
}

#
# lxc
#
resource "proxmox_lxc" "ct" {
  for_each = var.lxc

  # ---------- Identity & source ----------
  vmid        = each.value.vmid
  hostname    = each.key
  target_node = each.value.target_node
  ostemplate  = each.value.template

  # ---------- Lifecycle ----------
  onboot = each.value.onboot
  start  = each.value.start

  # ---------- Hardware ----------
  cores        = each.value.cores
  memory       = each.value.memory
  unprivileged = true

  # ---------- Storage ----------
  rootfs {
    storage = "local-lvm"
    size    = each.value.disk
  }

  # ---------- Network ----------
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = each.value.ip
    gw     = try(each.value.gw, null)
  }
  nameserver = try(each.value.nameserver, null)

  # ---------- User ----------
  ssh_public_keys = each.value.ssh_key

  # ---------- Misc ----------
  tags = length(try(each.value.tags, [])) > 0 ? join(";", sort(each.value.tags)) : null

  lifecycle {
    ignore_changes = [tags]
  }
}