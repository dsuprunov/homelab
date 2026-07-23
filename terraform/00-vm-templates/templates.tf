resource "proxmox_virtual_environment_file" "artifact" {
  for_each = var.image_versions

  content_type = "import"
  datastore_id = each.value.import_datastore_id
  node_name    = each.value.node_name

  source_file {
    checksum  = each.value.artifact_checksum
    file_name = coalesce(each.value.artifact_file_name, basename(each.value.artifact_path))
    path      = abspath("${path.module}/${each.value.artifact_path}")
  }
}

resource "proxmox_virtual_environment_vm" "template" {
  for_each = var.image_versions

  name        = each.value.template_name
  description = "Managed by Terraform from Packer artifact ${each.key}"
  node_name   = each.value.node_name
  vm_id       = each.value.template_vm_id
  tags        = each.value.tags

  template = true
  started  = false

  bios          = "ovmf"
  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  boot_order    = ["scsi0"]

  efi_disk {
    datastore_id = each.value.template_datastore_id
    file_format  = "raw"
    type         = "4m"
  }

  agent {
    enabled = true
  }

  cpu {
    cores   = 1
    sockets = 1
    type    = "host"
    numa    = false
  }

  memory {
    dedicated = 1024
    floating  = 0
  }

  disk {
    aio          = "io_uring"
    cache        = "none"
    datastore_id = each.value.template_datastore_id
    discard      = "on"
    import_from  = proxmox_virtual_environment_file.artifact[each.key].id
    interface    = "scsi0"
    iothread     = true
    size         = each.value.boot_disk_size
    ssd          = true
  }

  initialization {
    datastore_id = each.value.cloudinit_datastore_id
  }

  serial_device {
    device = "socket"
  }

  vga {
    type = "serial0"
  }

  rng {
    source = "/dev/urandom"
  }

  operating_system {
    type = "l26"
  }
}
