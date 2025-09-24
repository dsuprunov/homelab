### test-vm-nas

```bash
qm clone 9002 202 --name test-vm-nas --full 1

qm resize 202 scsi0 16G

qm set 202 \
  --scsi1 /dev/disk/by-id/nvme-SK_hynix_BC711_HFM256GD3JX013N_FJACN48881290CC52,discard=on,iothread=1,ssd=1 \
  --scsi2 local-lvm:cloudinit \
  --ipconfig0 ip=192.168.178.202/24,gw=192.168.178.1 \
  --nameserver 192.168.178.201 \
  --ciuser dms \
  --sshkeys ~/.ssh/homelab-ed25519.pub \
  --onboot 1
  
qm start 202

ssh dms@192.168.178.202
sudo apt update
sudo apt install -y qemu-guest-agent nfs-kernel-server parted

sudo systemctl enable --now qemu-guest-agent
sudo systemctl status qemu-guest-agent

sudo systemctl enable --now fstrim.timer
sudo systemctl status fstrim.timer

lsblk -o NAME,SIZE,MODEL,SERIAL,TYPE,MOUNTPOINT

#
# NFS Option A - Clean slate: Create new partition / wipe stored data 
#
DATA_DISK="/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1"

sudo wipefs -a -n "$DATA_DISK"
sudo wipefs -a    "$DATA_DISK"

sudo parted -s "$DATA_DISK" mklabel gpt mkpart data ext4 1MiB 100%
sudo mkfs.ext4 -F "${DATA_DISK}-part1"

sudo mkdir -p /srv/storage/disk1
UUID=$(sudo blkid -s UUID -o value "${DATA_DISK}-part1")
echo "UUID=$UUID /srv/storage/disk1 ext4 defaults 0 2" | sudo tee -a /etc/fstab
sudo systemctl daemon-reload
sudo mount -a

#
# NFS Option B - Safe attach: Reuse already created partition/data
#
DATA_PART="/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1-part1"

sudo mkdir -p /srv/storage/disk1
UUID=$(sudo blkid -s UUID -o value "$DATA_PART")
echo "UUID=$UUID /srv/storage/disk1 ext4 defaults 0 2" | sudo tee -a /etc/fstab
sudo systemctl daemon-reload
sudo mount -a

#
# NFS Common - Post-steps after A or B
#
findmnt -T /srv/storage/disk1
df -h /srv/storage/disk1

DATA_PART="/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1-part1"
sudo tune2fs -m 1 "$DATA_PART"

sudo mkdir -p /srv/nfs /etc/exports.d
echo "/srv/nfs *(fsid=0,ro,root_squash,sync)" | sudo tee /etc/exports.d/00-root.exports
sudo exportfs -ra && sudo exportfs -v

sudo systemctl enable --now nfs-server
sudo systemctl status nfs-server
```

### test-vm-nfs

```bash
qm clone 9001 211 --name test-vm-nfs --full 1

qm resize 211 scsi0 16G

qm set 211 \
  --scsi2 local-lvm:cloudinit \
  --ipconfig0 ip=192.168.178.211/24,gw=192.168.178.1 \
  --nameserver 192.168.178.201 \
  --ciuser dms \
  --sshkeys ~/.ssh/homelab-ed25519.pub \
  --onboot 1
  
qm start 211

ssh dms@192.168.178.211
sudo apt update
sudo apt install -y qemu-guest-agent nfs-common

sudo systemctl enable --now qemu-guest-agent
systemctl status qemu-guest-agent
```

### test-vm-iscsi

```bash
qm clone 9001 212 --name test-vm-iscsi --full 1

qm resize 212 scsi0 16G

qm set 212 \
  --scsi2 local-lvm:cloudinit \
  --ipconfig0 ip=192.168.178.212/24,gw=192.168.178.1 \
  --nameserver 192.168.178.201 \
  --ciuser dms \
  --sshkeys ~/.ssh/homelab-ed25519.pub \
  --onboot 1
  
qm start 212

ssh dms@192.168.178.212
sudo apt update
sudo apt install qemu-guest-agent

sudo systemctl enable --now qemu-guest-agent
systemctl status qemu-guest-agent
```