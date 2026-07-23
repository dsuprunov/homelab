image_versions = {
  ubuntu_26_04_20260723 = {
    artifact_path  = "../../packer/artifacts/ubuntu-26.04/20260723/ubuntu-26.04.qcow2"
    boot_disk_size = 8
    tags           = ["template", "ubuntu", "cloud-image", "packer"]
    template_name  = "tpl-ubuntu-26-04"
    template_vm_id = 9001
  }

  debian_13_20260723 = {
    artifact_path  = "../../packer/artifacts/debian-13/20260723/debian-13.qcow2"
    boot_disk_size = 8
    tags           = ["template", "debian", "cloud-image", "packer"]
    template_name  = "tpl-debian-13"
    template_vm_id = 9100
  }
}

image_aliases = {
  ubuntu_26_04 = "ubuntu_26_04_20260723"
  debian_13    = "debian_13_20260723"
}
