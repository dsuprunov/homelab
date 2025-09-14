output "vm" {
  value = {
    for k, vm in var.vm : k => {
      vmid        = vm.vmid
      name        = vm.name
      template    = vm.template
      target_node = vm.target_node
      state       = vm.state
      onboot      = vm.onboot
      memory      = vm.memory
      disk        = vm.disk
      cores       = vm.cores
      ipconfig    = vm.ipconfig
      nameserver  = try(vm.nameserver, null)
      user        = vm.user
    }
  }
}

output "ct" {
  value = {
    for k, ct in var.ct : k => {
      vmid        = ct.vmid
      name        = ct.name
      template    = ct.template
      target_node = ct.target_node
      start       = ct.start
      onboot      = ct.onboot
      memory      = ct.memory
      disk        = ct.disk
      cores       = ct.cores
      ip          = ct.ip
      gw          = try(ct.gw, null)
      nameserver  = try(ct.nameserver, null)
    }
  }
}