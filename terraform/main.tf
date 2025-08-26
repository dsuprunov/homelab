resource "proxmox_vm_qemu" "ubuntu-test-instance" {
  # ---------- Identity & source ----------
  vmid        = 1001
  name        = "ubuntu-test-instance"
  target_node = "pve"
  clone       = "ubuntu-24.04-cloud-template"
  full_clone  = true

  # ---------- Lifecycle (optional) ----------
  # vm_state         = "running"
  # automatic_reboot = true

  # ---------- Hardware: compute & platform ----------
  memory  = 1024
  balloon = 1024
  agent   = 1
  boot    = "order=scsi0"
  scsihw  = "virtio-scsi-single"

  cpu {
    cores = 1
  }

  # ---------- Storage ----------
  disks {
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = "16G"
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
  nameserver = "192.168.178.1"
  ipconfig0  = "ip=192.168.178.222/24,gw=192.168.178.1"
  skip_ipv6  = true
  ciuser     = "dms"
  sshkeys    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO8wQ3QpMwyZmfg1Hl97WByICUFVDKbT8yiyus7LWSW8 dsuprunov@gmail.com"
}