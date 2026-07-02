terraform {
  required_version = "= 1.15.7"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.111.0"
    }

    talos = {
      source  = "siderolabs/talos"
      version = "0.11.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
  }
}
