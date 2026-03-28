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

  dynamic "mount_point" {
    for_each = var.mount_points
    content {
      volume = mount_point.value.volume
      path   = mount_point.value.path
    }
  }

  # --- Networking ---
  dynamic "network_interface" {
    for_each = var.network_interfaces
    content {
      name     = "eth${network_interface.key}"
      bridge   = network_interface.value.bridge
      firewall = network_interface.value.firewall
    }
  }

  # --- Initialization ---
  initialization {
    hostname = var.name

    user_account {
      keys     = var.ssh_keys
      password = null
    }

    dynamic "ip_config" {
      for_each = var.network_interfaces
      content {
        ipv4 {
          address = ip_config.value.ipv4_address
          gateway = ip_config.value.ipv4_gateway
        }
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
