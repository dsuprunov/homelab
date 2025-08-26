

resource "proxmox_vm_qemu" "ubuntu-test-instance" {
  vmid        = 1001
  name        = "ubuntu-test-instance"
  target_node = "pve"
  clone       = "ubuntu-24.04-cloud-template"
  full_clone  = true
  agent       = 1
  memory      = 1024
  boot        = "order=scsi0"
  scsihw      = "virtio-scsi-single"

  cpu {
    cores = 1
  }

  ciupgrade  = true
  nameserver = "192.168.178.1"
  ipconfig0  = "ip=192.168.178.222/24,gw=192.168.178.1,ip6=dhcp"
  skip_ipv6  = true
  ciuser     = "dms"
  cipassword = "dms"

  serial {
    id = 0
  }

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

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }
}