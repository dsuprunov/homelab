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
  dynamic "disk" {
    for_each = { for d in var.disks : d.interface => d }
    iterator = d

    content {
      datastore_id = coalesce(d.value.datastore_id, var.datastore_id)

      interface   = d.key
      size        = d.value.size
      import_from = d.key == "scsi0" ? var.import_from : null

      aio      = "io_uring"
      cache    = "none"
      discard  = "on"
      iothread = true
      ssd      = true
    }
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

    dynamic "dns" {
      for_each = length(var.nameservers) > 0 ? [1] : []
      content {
        servers = var.nameservers
      }
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
