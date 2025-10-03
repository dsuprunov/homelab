### Ubuntu 24.04 Noble Numbat

```bash
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img

qm create 9001 \
  --name ubuntu-24.04-ci \
  --machine q35 --ostype l26 \
  --memory 1024 --balloon 1024 \
  --cpu host --cores 1 --sockets 1 --numa 0 \
  --scsihw virtio-scsi-single \
  --scsi0 local-lvm:0,import-from=/root/noble-server-cloudimg-amd64.img,discard=on,iothread=1,ssd=1 \
  --bios ovmf --efidisk0 local-lvm:1,efitype=4m,pre-enrolled-keys=1 \
  --boot order=scsi0 \
  --net0 virtio,bridge=vmbr0,firewall=1 \
  --serial0 socket --vga serial0 \
  --rng0 source=/dev/urandom \
  --agent 1
  
qm template 9001

qm clone 9001 211 --name test-vm-211 --full 1

qm resize 211 scsi0 8G

qm set 211 \
  --scsi2 local-lvm:cloudinit \
  --ipconfig0 ip=192.168.178.211/24,gw=192.168.178.1 \
  --nameserver 192.168.178.1 \
  --ciuser dms \
  --sshkeys ~/.ssh/homelab-ed25519.pub
  
qm start 211
```

### Debian 13 Trixie 

```bash
wget https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2

qm create 9002 \
  --name debian-13-ci \
  --machine q35 --ostype l26 \
  --memory 1024 --balloon 1024 \
  --cpu host --cores 1 --sockets 1 --numa 0 \
  --scsihw virtio-scsi-single \
  --scsi0 local-lvm:0,import-from=/root/debian-13-genericcloud-amd64.qcow2,discard=on,iothread=1,ssd=1 \
  --bios ovmf --efidisk0 local-lvm:1,efitype=4m,pre-enrolled-keys=1 \
  --boot order=scsi0 \
  --net0 virtio,bridge=vmbr0,firewall=1 \
  --serial0 socket --vga serial0 \
  --rng0 source=/dev/urandom \
  --agent 1
  
qm template 9002

qm clone 9002 212 --name test-vm-212 --full 1

qm resize 212 scsi0 8G

qm set 212 \
  --scsi2 local-lvm:cloudinit \
  --ipconfig0 ip=192.168.178.212/24,gw=192.168.178.1 \
  --nameserver 192.168.178.1 \
  --ciuser dms \
  --sshkeys ~/.ssh/homelab-ed25519.pub
  
qm start 212
```

### LXC  Debian 12 Standart

```bash
pveam update

pveam available --section system

pveam download local debian-12-standard_12.7-1_amd64.tar.zst

pveam list local
```

### Bootstrap

```bash
sudo apt update
sudo apt install qemu-guest-agent
sudo systemctl start qemu-guest-agent
```