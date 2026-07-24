locals {
  cluster = {
    name               = "talos-proxmox-cluster"
    api_vip            = "192.168.178.230"
    api_fqdn           = "k8s-api.home.arpa"
    api_port           = 6443
    talos_version      = "v1.13.7"
    kubernetes_version = "v1.36.2"
    install_disk       = "/dev/sda"
    install_image      = "factory.talos.dev/nocloud-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.13.7"
    iso_file_id        = "local:iso/nocloud-amd64.iso"
    nameservers        = ["192.168.178.206"]
  }
}
