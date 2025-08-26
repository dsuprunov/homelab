```bash
ssh root@192.168.178.201
```

```bash
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img

mkdir -p /var/lib/vz/snippets

cat >/var/lib/vz/snippets/ubuntu-24.04-cloud-user.yml <<'EOF'
#cloud-config

package_update: true
package_upgrade: true
# package_reboot_if_required: false

packages:
  - qemu-guest-agent

ssh_pwauth: false

runcmd:
  - [ bash, -lc, 'systemctl start qemu-guest-agent' ]
  - [ bash, -lc, 'systemctl try-reload-or-restart ssh' ]

timezone: UTC
EOF

qm create 9001 \
  --name ubuntu-24.04-cloud-template --ostype l26 \
  --memory 1024 --cpu host --cores 1 --sockets 1 --numa 0 --agent 1 --balloon 0 \
  --machine q35 --bios ovmf \
  --efidisk0 local-lvm:0,efitype=4m,pre-enrolled-keys=1 \
  --scsihw virtio-scsi-single \
  --scsi0 local-lvm:0,import-from=/root/noble-server-cloudimg-amd64.img,discard=on,iothread=1,ssd=1 \
  --boot order=scsi0 \
  --net0 virtio,bridge=vmbr0,firewall=1 \
  --rng0 source=/dev/urandom \
  --ide2 local-lvm:cloudinit \
  --serial0 socket --vga serial0 \
  --cicustom vendor=local:snippets/ubuntu-24.04-cloud-user.yml  
  
qm template 9001
```

```bash
qm clone 9001 101 --name test --full 1

qm resize 101 scsi0 16G

qm set 101 \
  --memory 1024 --balloon 1024 --cores 1 \
  --ipconfig0 ip=192.168.178.211/24,gw=192.168.178.1 \
  --nameserver 192.168.178.1 --searchdomain local \
  --ciuser dms \
  --sshkeys ~/.ssh/homelab-dsuprunov-ed25519.pub

qm cloudinit update 101
  
qm start 101

ssh dms@192.168.178.211

sudo cloud-init status --long
systemctl is-failed cloud-final
systemctl status cloud-final -l --no-pager
sudo journalctl -u cloud-init-local -u cloud-init -u cloud-config -u cloud-final -b --no-pager
```