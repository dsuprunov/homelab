module "proxmox_vm" {
  for_each = var.vms

  source = "../modules/proxmox-vm-talos"

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

  disks = each.value.disks

  datastore_id           = each.value.datastore_id
  cloudinit_datastore_id = each.value.cloudinit_datastore_id

  network_interfaces = each.value.network_interfaces
  nameservers        = each.value.nameservers

  image_file_id = proxmox_download_file.talos_image[each.value.image].id

  started = each.value.started
  on_boot = each.value.on_boot

  qemu_agent_enabled = each.value.qemu_agent_enabled
  qemu_agent_timeout = each.value.qemu_agent_timeout
}
