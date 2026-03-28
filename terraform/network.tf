resource "proxmox_virtual_environment_network_linux_bridge" "vmbr1" {
  node_name = "pve"
  name      = "vmbr1"
}
