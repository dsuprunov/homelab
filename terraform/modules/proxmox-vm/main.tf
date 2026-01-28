resource "proxmox_virtual_environment_vm" "vm" {
  # --- Identity / placement ---
  name      = var.name
  node_name = var.node_name
  vm_id     = var.vm_id
  tags      = var.tags

  # --- Lifecycle / power state ---
  started         = var.started
  on_boot         = var.on_boot
  stop_on_destroy = true

  # --- Firmware / machine / boot ---
  bios          = "ovmf"
  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  boot_order    = ["scsi0"]

  efi_disk {
    datastore_id = var.datastore_id
    file_format  = "raw"
    type         = "4m"
  }

  # --- Guest agent ---
  agent {
    enabled = var.qemu_agent_enabled
    timeout = var.qemu_agent_timeout
  }

  # --- Compute ---
  cpu {
    cores   = var.cores
    sockets = var.sockets
    type    = "host"
    numa    = false
  }

  memory {
    dedicated = var.memory
    floating  = var.balloon
  }

  # --- Storage ---
  disk {
    datastore_id = var.datastore_id
    import_from  = var.import_from

    interface = "scsi0"
    size      = var.disk

    aio      = "io_uring"
    cache    = "none"
    discard  = "on"
    iothread = true
    ssd      = true
  }

  # --- Networking ---
  network_device {
    bridge   = var.bridge
    model    = "virtio"
    firewall = var.firewall
  }

  # --- Cloud-init / initial provisioning ---
  initialization {
    datastore_id = var.cloudinit_datastore_id

    user_account {
      username = var.user
      keys     = var.ssh_keys
    }

    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = var.ipv4_gateway
      }
    }

    dns {
      servers = var.nameservers
    }
  }

  # --- Console / devices ---
  serial_device {
    device = "socket"
  }

  vga {
    type = "serial0"
  }

  rng {
    source = "/dev/urandom"
  }

  # --- Guest OS hint ---
  operating_system {
    type = "l26"
  }
}
