> **Note — UID/GID pool**
>
> We reserve service accounts **UID/GID** in the **3000–3999** range.
> - 3001 - `vm-pi-hole` 

### vm-nas

```bash
NAS_DISK_ID="/dev/disk/by-id/nvme-SK_hynix_BC711_HFM256GD3JX013N_FJACN48881290CC52"
NAS_STORAGE_ID="nas-lvm"
NAS_LVM_GROUP="nas"
NAS_VOLUME_ID="vm-202-disk-1"

pvscan
vgscan

lsblk -no NAME,SIZE,TYPE "$(readlink -f ${NAS_DISK_ID})"

#
# Option A — Clean state (wipe/create new VG on whole disk)
#
sgdisk --zap-all ${NAS_DISK_ID} && wipefs -a -f ${NAS_DISK_ID}

pvcreate ${NAS_DISK_ID}
vgcreate ${NAS_LVM_GROUP} ${NAS_DISK_ID}

lvcreate -l 100%FREE -n ${NAS_VOLUME_ID} ${NAS_LVM_GROUP}

#
# Option B — Safe attach (reuse existing LVM VG with data)
#
vgchange -ay ${NAS_LVM_GROUP}

#
# NFS Common - Post-steps after "Option A" or "Option B"
#
grep -q "^${NAS_STORAGE_ID}:" /etc/pve/storage.cfg || pvesm add lvm "${NAS_STORAGE_ID}" --vgname "${NAS_LVM_GROUP}" --content images

pvesm status
pvesm list ${NAS_STORAGE_ID}

qm clone 9002 202 --name vm-nas --full 1
qm resize 202 scsi0 16G
qm set 202 \
  --scsihw virtio-scsi-single \
  --scsi1 ${NAS_STORAGE_ID}:${NAS_VOLUME_ID},discard=on,iothread=1,ssd=1 \
  --scsi2 local-lvm:cloudinit \
  --ipconfig0 ip=192.168.178.202/24,gw=192.168.178.1 \
  --nameserver 192.168.178.201 \
  --ciuser debian \
  --sshkeys ~/.ssh/homelab-ed25519.pub \
  --onboot 1
  
qm start 202

lvs
lvs -o vg_name,lv_name,lv_size,lv_attr,devices
```

```bash
qm set 202 \
  --scsihw virtio-scsi-single \
  --scsi1 nas-lvm:vm-202-disk-1,discard=on,iothread=1,ssd=1
```