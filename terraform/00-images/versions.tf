terraform {
  required_version = "= 1.15.7"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.111.0"
    }
  }
}
