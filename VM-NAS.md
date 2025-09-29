> **Note — UID/GID pool**
>
> We reserve service accounts **UID/GID** in the **3000–3999** range.
> - 3001 - `test-vm-nfs`
> - 3002 - `vm-pi-hole` 

### vm-nas

```bash
qm clone 9002 202 --name vm-nas --full 1

qm resize 202 scsi0 16G

qm set 202 \
  --scsihw virtio-scsi-single \
  --scsi1 /dev/disk/by-id/nvme-SK_hynix_BC711_HFM256GD3JX013N_FJACN48881290CC52,discard=on,iothread=1,ssd=1 \
  --scsi2 local-lvm:cloudinit \
  --ipconfig0 ip=192.168.178.202/24,gw=192.168.178.1 \
  --nameserver 192.168.178.201 \
  --ciuser debian \
  --sshkeys ~/.ssh/homelab-ed25519.pub \
  --onboot 1
  
qm start 202

ssh debian@192.168.178.202
sudo apt update
sudo apt install -y qemu-guest-agent nfs-kernel-server parted acl

sudo systemctl enable --now qemu-guest-agent
sudo systemctl status qemu-guest-agent

sudo systemctl enable --now fstrim.timer
sudo systemctl status fstrim.timer

lsblk -o NAME,SIZE,MODEL,SERIAL,TYPE,MOUNTPOINT

DATA_DISK="/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1"

#
# NFS Option A — Clean state (wipe/create new partition)
#
sudo wipefs -a -n "$DATA_DISK"
sudo wipefs -a    "$DATA_DISK"

sudo parted -s "$DATA_DISK" mklabel gpt mkpart data ext4 1MiB 100%
sudo mkfs.ext4 -F "${DATA_DISK}-part1"

#
# NFS Option B — Safe attach (reuse existing partition)
#

#
# NFS Common - Post-steps after "Option A" or "Option B"
#
sudo mkdir -p /srv/storage/disk1
UUID=$(sudo blkid -s UUID -o value "${DATA_DISK}-part1")
grep -qE "^[^#].*\s/srv/storage/disk1\s" /etc/fstab || echo "UUID=$UUID /srv/storage/disk1 ext4 noatime 0 2" | sudo tee -a /etc/fstab
sudo systemctl daemon-reload
sudo mount /srv/storage/disk1

findmnt -T /srv/storage/disk1
sudo test -d /srv/storage/disk1/lost+found || echo "ERROR: /srv/storage/disk1 is not the data disk (not mounted)"

sudo tune2fs -m 1 /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1-part1

sudo mkdir -p /srv/nfs /etc/exports.d
sudo install -d -m 0755 /etc/nfs.conf.d
sudo tee /etc/nfs.conf.d/10-nfsv4-only.conf >/dev/null <<'EOF'
[nfsd]
vers2 = n
vers3 = n
udp = n
vers4 = y
EOF
sudo systemctl enable --now nfs-server
sudo systemctl restart nfs-server
sudo systemctl status nfs-server
echo "/srv/nfs *(fsid=0,ro,sync,no_subtree_check,crossmnt)" | sudo tee /etc/exports.d/00-root.exports
sudo exportfs -ra && sudo exportfs -v
```

### per-client: test-vm-nfs (192.168.178.211, UID/GID=3001)

```bash
SHARE="test-vm-nfs"
CLIENT_IP="192.168.178.211/32"
SVC_UID=3001
SVC_GID=3001

sudo groupadd -g "$SVC_GID" "$SHARE"
sudo useradd -u "$SVC_UID" -g "$SVC_GID" -s /usr/sbin/nologin -M "$SHARE"

sudo test -d /srv/storage/disk1/lost+found || echo "ERROR: /srv/storage/disk1 is not mounted; mount it first"

sudo mkdir -p "/srv/storage/disk1/$SHARE"
sudo chown "$SHARE:$SHARE" "/srv/storage/disk1/$SHARE"
sudo chmod 2770 "/srv/storage/disk1/$SHARE"
sudo setfacl -b "/srv/storage/disk1/$SHARE"
sudo setfacl -k "/srv/storage/disk1/$SHARE"

sudo mkdir -p "/srv/nfs/$SHARE"
grep -qE "^[^#].*\s/srv/nfs/$SHARE\s" /etc/fstab || echo "/srv/storage/disk1/$SHARE /srv/nfs/$SHARE none bind 0 0" | sudo tee -a /etc/fstab

sudo systemctl daemon-reload
sudo mount "/srv/nfs/$SHARE"

echo "/srv/nfs/$SHARE $CLIENT_IP(rw,all_squash,sync,no_subtree_check,anonuid=$SVC_UID,anongid=$SVC_GID)" | sudo tee "/etc/exports.d/$SHARE.exports"
sudo exportfs -ra

sudo exportfs -v
findmnt -T "/srv/nfs/$SHARE"
sudo cat /proc/fs/nfsd/versions
ls -ld "/srv/storage/disk1/$SHARE"
```