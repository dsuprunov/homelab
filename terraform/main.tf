resource "proxmox_vm_qemu" "vm" {
  for_each = var.vm

  # ---------- Identity & source ----------
  vmid        = each.value.vmid
  name        = each.value.name
  target_node = each.value.target_node
  clone       = each.value.template
  full_clone  = true

  # ---------- Lifecycle ----------
  vm_state = each.value.state
  onboot   = each.value.onboot
  # automatic_reboot = true

  # ---------- Hardware: compute & platform ----------
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
          storage  = "local-lvm"
          size     = each.value.disk
          iothread = true
        }
      }
    }
    ide {
      ide1 {
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
  cicustom   = "vendor=local:snippets/ubuntu-24.04-cloud-vendor.yml"
  ciupgrade  = true
  nameserver = try(each.value.nameserver, null)
  ipconfig0  = each.value.ipconfig
  skip_ipv6  = true
  ciuser     = each.value.user
  cipassword = "dms"
  sshkeys    = each.value.ssh_key
}