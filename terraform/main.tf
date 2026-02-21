resource "proxmox_virtual_environment_download_file" "cloud_image" {
  for_each = var.cloud_images

  content_type = each.value.content_type
  datastore_id = each.value.datastore_id
  node_name    = each.value.node_name

  url       = each.value.url
  file_name = each.value.file_name
  # overwrite           = true
  # overwrite_unmanaged = true
}

module "proxmox_vm" {
  for_each = var.vms

  source = "./modules/proxmox-vm"

  providers = {
    proxmox = proxmox
  }

  name      = each.key
  node_name = each.value.node_name
  vm_id     = each.value.vm_id
  tags      = each.value.tags

  cores   = each.value.cores
  sockets = each.value.sockets
  memory  = each.value.memory
  balloon = each.value.balloon

  disks    = each.value.disks
  virtiofs = each.value.virtiofs

  datastore_id           = each.value.datastore_id
  cloudinit_datastore_id = each.value.cloudinit_datastore_id

  bridge   = each.value.bridge
  firewall = each.value.firewall

  ipv4_address = each.value.ipv4_address
  ipv4_gateway = each.value.ipv4_gateway
  nameservers  = each.value.nameservers
  user         = each.value.user
  ssh_keys     = each.value.ssh_keys

  import_from = proxmox_virtual_environment_download_file.cloud_image[each.value.image].id

  started = each.value.started
  on_boot = each.value.on_boot

  qemu_agent_enabled = each.value.qemu_agent_enabled
  qemu_agent_timeout = each.value.qemu_agent_timeout

  cloud_config_vendor_data_file = each.value.cloud_config_vendor_data_file
}

module "proxmox_ct" {
  for_each = var.cts

  source = "./modules/proxmox-ct"

  providers = {
    proxmox = proxmox
  }

  name      = each.key
  node_name = each.value.node_name
  ct_id     = each.value.ct_id
  tags      = each.value.tags

  os_template  = each.value.os_template
  os_type      = each.value.os_type
  nesting      = each.value.nesting
  unprivileged = each.value.unprivileged

  cpu_cores = each.value.cpu_cores
  memory    = each.value.memory
  swap      = each.value.swap
  disk_size = each.value.disk_size

  datastore_id = each.value.datastore_id

  bridge   = each.value.bridge
  firewall = each.value.firewall

  ipv4_address = each.value.ipv4_address
  ipv4_gateway = each.value.ipv4_gateway
  nameservers  = each.value.nameservers
  ssh_keys     = each.value.ssh_keys

  started = each.value.started
  on_boot = each.value.on_boot
}
