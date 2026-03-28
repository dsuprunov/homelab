cts = {
  ct-test-252 = {
    ct_id = 252
    tags  = ["ct", "test"]

    os_template = "local:vztmpl/dsuprunov-dummy-portal-latest.tar"
    os_type     = "alpine"

    cpu_cores = 1
    memory    = 128
    disk_size = 1

    network_interfaces = [
      { bridge = "vmbr0", ipv4_address = "192.168.178.252/24", ipv4_gateway = "192.168.178.1" }
    ]
    nameservers = ["192.168.178.1"]
  }

  ct-test-253 = {
    ct_id = 253
    tags  = ["ct", "test"]

    os_template = "local:vztmpl/alpine-latest.tar"
    os_type     = "alpine"

    cpu_cores = 1
    memory    = 128
    disk_size = 1

    network_interfaces = [
      { bridge = "vmbr0", ipv4_address = "192.168.178.253/24", ipv4_gateway = "192.168.178.1" }
    ]
    nameservers = ["192.168.178.1"]
  }
}
