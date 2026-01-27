resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  # --- Identity / placement ---
  name      = "test-ubuntu"
  node_name = "pve"
  vm_id     = 222
  tags      = ["test", "ubuntu"]

  # --- Lifecycle / power state ---
  started         = true
  on_boot         = true
  stop_on_destroy = true # ToDo

  # --- Firmware / machine / boot ---
  bios          = "ovmf"
  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  boot_order    = ["scsi0"]

  efi_disk {
    datastore_id = "local-lvm"
    file_format  = "raw"
    type         = "4m"
  }

  # --- Guest agent ---
  agent {
    enabled = false # NOTE: qemu-guest-agent must be installed+enabled inside the template/VM.
  }

  # --- Compute ---
  cpu {
    cores   = 1
    type    = "host"
    sockets = 1
    numa    = false
  }

  memory {
    dedicated = 1024
    floating  = 0 # NOTE: floating=0 disables ballooning
  }

  # --- Storage ---
  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id

    interface = "scsi0"
    size      = 8

    # performance / behavior
    aio      = "io_uring"
    cache    = "none"
    discard  = "on"
    iothread = true
    ssd      = true
  }

  # --- Networking ---
  network_device {
    bridge   = "vmbr0"
    model    = "virtio"
    firewall = true
  }

  # --- Cloud-init / initial provisioning ---
  initialization {
    datastore_id = "local-lvm"

    user_account {
      username = "dms"
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"
      ]
    }

    ip_config {
      ipv4 {
        address = "192.168.178.222/24"
        gateway = "192.168.178.1"
      }
    }

    dns {
      servers = ["192.168.178.1"]
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

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = "pve"

  url       = "https://cloud-images.ubuntu.com/releases/noble/release/ubuntu-24.04-server-cloudimg-amd64.img"
  file_name = "ubuntu-24.04-server-cloudimg-amd64.qcow2"
}