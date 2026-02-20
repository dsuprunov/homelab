resource "proxmox_virtual_environment_container" "ct" {
  # --- Identity / placement ---
  node_name    = var.node_name
  vm_id        = var.ct_id
  tags         = var.tags
  unprivileged = var.unprivileged

  # --- Lifecycle / power state ---
  started       = var.started
  start_on_boot = var.on_boot

  # --- Compute ---
  cpu {
    cores = var.cpu_cores
  }

  features {
    nesting = var.nesting
  }

  memory {
    dedicated = var.memory
    swap      = var.swap
  }

  # --- Storage ---
  disk {
    datastore_id = var.datastore_id
    size         = var.disk_size
  }

  # --- Networking ---
  network_interface {
    name     = "eth0"
    bridge   = var.bridge
    firewall = var.firewall
  }

  # --- Initialization ---
  initialization {
    hostname = var.name

    user_account {
      keys     = var.ssh_keys
      password = null
    }

    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = var.ipv4_gateway
      }
    }

    dynamic "dns" {
      for_each = length(var.nameservers) > 0 ? [1] : []
      content {
        servers = var.nameservers
      }
    }
  }

  # --- Guest OS template ---
  operating_system {
    template_file_id = var.os_template
    type             = var.os_type
  }
}
