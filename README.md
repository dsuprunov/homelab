## Configure Proxmox

### Remove local-lvm

```
lvremove /dev/pve/data
lvresize -l +100%FREE /dev/pve/root
resize2fs /dev/mapper/pve-root
lsblk
```

```
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img

mv noble-server-cloudimg-amd64.img noble-server-cloudimg-amd64.qcow2

qm set 101 --serial0 socket --vga serial0

qemu-img resize noble-server-cloudimg-amd64.qcow2 32G

qm disk import 101 noble-server-cloudimg-amd64.qcow2 local

sudo apt install qemu-guest-agent -y
```

```
docker compose -f docker-compose.yml run --rm terraform init --upgrade

docker compose -f docker-compose.yml run --rm terraform plan

docker compose -f docker-compose.yml run --rm terraform appy
```

```
ssh root@192.168.178.211 -i "%USERPROFILE%\.ssh\homelab-dsuprunov-ed25519"
```