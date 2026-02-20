cts = {
  ct-pihole = {
    ct_id = 201
    tags  = ["ct", "pihole"]

    os_template = "local:vztmpl/pihole-latest.tar"
    os_type     = "alpine"

    cpu_cores = 1
    memory    = 256
    disk_size = 4

    ipv4_address = "192.168.178.201/24"
    ipv4_gateway = "192.168.178.1"
    nameservers  = ["192.168.178.1"]
  }
}
