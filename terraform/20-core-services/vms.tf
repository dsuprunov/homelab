module "proxmox_vm" {
  for_each = var.vms

  source = "../modules/proxmox-vm"

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

  network_interfaces = each.value.network_interfaces
  nameservers        = each.value.nameservers
  user               = each.value.user
  ssh_keys           = each.value.ssh_keys

  import_from = data.terraform_remote_state.images.outputs.images[each.value.image]

  started = each.value.started
  on_boot = each.value.on_boot

  qemu_agent_enabled = each.value.qemu_agent_enabled
  qemu_agent_timeout = each.value.qemu_agent_timeout

  cloud_config_vendor_data_file = each.value.cloud_config_vendor_data_file
}
