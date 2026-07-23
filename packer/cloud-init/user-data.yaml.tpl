#cloud-config
users:
  - default
  - name: ${SSH_USERNAME}
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
chpasswd:
  expire: false
  users:
    - name: ${SSH_USERNAME}
      password: ${SSH_PASSWORD}
      type: text
ssh_pwauth: true
disable_root: true
package_update: false
