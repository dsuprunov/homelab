vms = {
  test-1 = {
    vmid        = 1101
    name        = "test-1"
    template    = "ubuntu-24.04-cloud-template"
    target_node = "pve"
    memory      = 1024
    disk        = "16G"
    cores       = 1
    ipconfig    = "ip=192.168.178.211/24,gw=192.168.178.1"
    nameserver  = "192.168.178.1"
    user        = "dms"
    ssh_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO8wQ3QpMwyZmfg1Hl97WByICUFVDKbT8yiyus7LWSW8 dsuprunov@gmail.com"
  }

  test-2 = {
    vmid        = 1102
    name        = "test-2"
    template    = "ubuntu-24.04-cloud-template"
    target_node = "pve"
    memory      = 1024
    disk        = "16G"
    cores       = 1
    ipconfig    = "ip=192.168.178.212/24,gw=192.168.178.1"
    nameserver  = "192.168.178.1"
    user        = "dms"
    ssh_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO8wQ3QpMwyZmfg1Hl97WByICUFVDKbT8yiyus7LWSW8 dsuprunov@gmail.com"
  }

  test-3 = {
    vmid        = 1103
    name        = "test-3"
    template    = "ubuntu-24.04-cloud-template"
    target_node = "pve"
    memory      = 1024
    disk        = "16G"
    cores       = 1
    ipconfig    = "ip=192.168.178.213/24,gw=192.168.178.1"
    nameserver  = "192.168.178.1"
    user        = "dms"
    ssh_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO8wQ3QpMwyZmfg1Hl97WByICUFVDKbT8yiyus7LWSW8 dsuprunov@gmail.com"
  }
}
