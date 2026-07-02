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
  scsi_hardware = "virtio-scsi-pci"
  boot_order    = ["scsi0", "ide0"]

  efi_disk {
    datastore_id = var.datastore_id
    file_format  = "raw"
    type         = "4m"
  }

  cdrom {
    file_id   = var.image_file_id
    interface = "ide0"
  }

  # --- Guest agent ---
  agent {
    enabled = var.qemu_agent_enabled
    timeout = var.qemu_agent_timeout

    wait_for_ip {
      disabled = true
    }
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

      aio      = "io_uring"
      cache    = "none"
      discard  = "on"
      ssd      = true
    }
  }

  # --- Networking ---
  dynamic "network_device" {
    for_each = var.network_interfaces
    iterator = nic

    content {
      bridge   = nic.value.bridge
      model    = nic.value.model
      firewall = nic.value.firewall
    }
  }

  # --- NoCloud initial network data ---
  initialization {
    datastore_id = var.cloudinit_datastore_id

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
