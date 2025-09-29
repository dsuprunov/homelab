vm = {
  vm-nas = {
    vmid        = 202
    tags        = ["debian", "nas"]
    template    = "debian-13-ci"
    target_node = "pve"
    state       = "running"
    onboot      = true
    memory      = 1024
    disk        = "8G"
    cores       = 1
    ipconfig    = "ip=192.168.178.202/24,gw=192.168.178.1"
    nameserver  = "192.168.178.1"
    user        = "debian"
    ssh_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"
  }

  vm-pi-hole = {
    vmid        = 203
    tags        = ["ubuntu", "pi-hole"]
    template    = "ubuntu-24.04-ci"
    target_node = "pve"
    state       = "running"
    onboot      = true
    memory      = 1024
    disk        = "8G"
    cores       = 1
    ipconfig    = "ip=192.168.178.203/24,gw=192.168.178.1"
    nameserver  = "192.168.178.1"
    user        = "ubuntu"
    ssh_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"
  }
}
