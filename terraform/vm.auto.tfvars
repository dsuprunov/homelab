vm = {
  test-vm-1 = {
    vmid        = 211
    name        = "test-vm-1"
    template    = "ubuntu-24.04-cloudimg"
    target_node = "pve"
    state       = "running"
    onboot      = true
    memory      = 1024
    disk        = "16G"
    cores       = 1
    ipconfig    = "ip=192.168.178.211/24,gw=192.168.178.1"
    nameserver  = "192.168.178.1"
    user        = "dms"
    ssh_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"
  }

  test-vm-2 = {
    vmid        = 212
    name        = "test-vm-2"
    template    = "ubuntu-24.04-cloudimg"
    target_node = "pve"
    state       = "running"
    onboot      = true
    memory      = 1024
    disk        = "16G"
    cores       = 1
    ipconfig    = "ip=192.168.178.212/24,gw=192.168.178.1"
    nameserver  = "192.168.178.1"
    user        = "dms"
    ssh_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"
  }

  test-vm-3 = {
    vmid        = 213
    name        = "test-vm-3"
    template    = "ubuntu-24.04-cloudimg"
    target_node = "pve"
    state       = "running"
    onboot      = true
    memory      = 1024
    disk        = "16G"
    cores       = 1
    ipconfig    = "ip=192.168.178.213/24,gw=192.168.178.1"
    nameserver  = "192.168.178.1"
    user        = "dms"
    ssh_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"
  }
}
