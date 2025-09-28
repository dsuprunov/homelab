output "vm" {
  value = {
    for k, vm in var.vm : k => {
      vmid        = vm.vmid
      template    = vm.template
      # target_node = vm.target_node
      # state       = vm.state
      # onboot      = vm.onboot
      memory      = vm.memory
      disk        = vm.disk
      cores       = vm.cores
      ipconfig    = vm.ipconfig
      nameserver  = try(vm.nameserver, null)
      user        = vm.user
      tags        = join(";", coalesce(vm.tags, []))
    }
  }
}

output "lxc" {
  value = {
    for k, lxc in var.lxc : k => {
      vmid        = lxc.vmid
      template    = lxc.template
      # target_node = lxc.target_node
      # start       = lxc.start
      # onboot      = lxc.onboot
      memory      = lxc.memory
      disk        = lxc.disk
      cores       = lxc.cores
      ip          = lxc.ip
      gw          = try(lxc.gw, null)
      nameserver  = try(lxc.nameserver, null)
      tags        = join(";", coalesce(lxc.tags, []))
    }
  }
}