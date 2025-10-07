vm = {
  # vm-nas = {
  #   vmid       = 202
  #   tags       = ["debian", "nas"]
  #   template   = "debian-13-ci"
  #   cores      = 1
  #   memory     = 1024
  #   disk       = "8G"
  #   ipconfig   = "ip=192.168.178.202/24,gw=192.168.178.1"
  #   nameserver = "192.168.178.1"
  #   user       = "debian"
  #   ssh_key    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"
  #   attachments = {
  #     scsi1 = {
  #       passthrough = {
  #         file = "/dev/disk/by-id/nvme-SK_hynix_BC711_HFM256GD3JX013N_FJACN48881290CC52"
  #       }
  #     }
  #   }
  # }

  vm-pi-hole = {
    vmid       = 203
    tags       = ["ubuntu", "pi-hole"]
    template   = "ubuntu-24.04-ci"
    cores      = 1
    memory     = 1024
    disk       = "8G"
    ipconfig   = "ip=192.168.178.203/24,gw=192.168.178.1"
    nameserver = "192.168.178.1"
    user       = "ubuntu"
    ssh_key    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"
  }

  #
  # K8S
  #
  vm-k8s-api-lb-01 = {
    vmid       = 222
    tags       = ["ubuntu", "k8s", "lb"]
    template   = "ubuntu-24.04-ci"
    cores      = 1
    memory     = 1024
    disk       = "8G"
    ipconfig   = "ip=192.168.178.222/24,gw=192.168.178.1"
    nameserver = "192.168.178.203"
    user       = "ubuntu"
    ssh_key    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"
  }

  vm-k8s-api-lb-02 = {
    vmid       = 223
    tags       = ["ubuntu", "k8s", "lb"]
    template   = "ubuntu-24.04-ci"
    cores      = 1
    memory     = 1024
    disk       = "8G"
    ipconfig   = "ip=192.168.178.223/24,gw=192.168.178.1"
    nameserver = "192.168.178.203"
    user       = "ubuntu"
    ssh_key    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"
  }

  vm-k8s-control-01 = {
    vmid       = 224
    tags       = ["ubuntu", "k8s", "control"]
    template   = "ubuntu-24.04-ci"
    cores      = 2
    memory     = 3072
    balloon    = 0
    disk       = "43G"
    ipconfig   = "ip=192.168.178.224/24,gw=192.168.178.1"
    nameserver = "192.168.178.203"
    user       = "ubuntu"
    ssh_key    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"
  }

  # vm-k8s-control-02 = {
  #   vmid       = 225
  #   tags       = ["ubuntu", "k8s", "control"]
  #   template   = "ubuntu-24.04-ci"
  #   cores      = 2
  #   memory     = 3072
  #   balloon    = 0
  #   disk       = "32G"
  #   ipconfig   = "ip=192.168.178.225/24,gw=192.168.178.1"
  #   nameserver = "192.168.178.203"
  #   user       = "ubuntu"
  #   ssh_key    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"
  # }

  vm-k8s-worker-01 = {
    vmid       = 227
    tags       = ["ubuntu", "k8s", "worker"]
    template   = "ubuntu-24.04-ci"
    cores      = 4
    memory     = 4096
    balloon    = 0
    disk       = "64G"
    ipconfig   = "ip=192.168.178.227/24,gw=192.168.178.1"
    nameserver = "192.168.178.203"
    user       = "ubuntu"
    ssh_key    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"
    attachments = {
      scsi1 = {
        disk = {
          storage = "local-lvm"
          size    = "16G"
        }
      }
    }
  }

  vm-k8s-worker-02 = {
    vmid       = 228
    tags       = ["ubuntu", "k8s", "worker"]
    template   = "ubuntu-24.04-ci"
    cores      = 4
    memory     = 4096
    balloon    = 0
    disk       = "64G"
    ipconfig   = "ip=192.168.178.228/24,gw=192.168.178.1"
    nameserver = "192.168.178.203"
    user       = "ubuntu"
    ssh_key    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"
    attachments = {
      scsi1 = {
        disk = {
          storage = "local-lvm"
          size    = "16G"
        }
      }
    }
  }
}