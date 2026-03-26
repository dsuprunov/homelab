```bash
pveum user token add root@pam terraform --privsep 0
```

```bash
#
# settings
#
export \
  DISK='/dev/disk/by-id/nvme-SK_hynix_BC711_HFM256GD3JX013N_FJACN48881290CC52' \
  PART='/dev/disk/by-id/nvme-SK_hynix_BC711_HFM256GD3JX013N_FJACN48881290CC52-part1' \
  MNT='/mnt/pve/local-data' \
  STORAGE='local-data'

#
# init
#
sgdisk -n 1:0:0 -t 1:8300 -c 1:local-data "$DISK"
partx -u "$DISK"
udevadm settle
mkfs.ext4 -F -L local-data "$PART"

#
# reuse
#
partx -u "$DISK"
udevadm settle
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,PARTLABEL "$DISK"
blkid "$PART"

#
# common
#
install -d -m 0755 "$MNT"
UUID="$(blkid -s UUID -o value "$PART")"
grep -q " $MNT " /etc/fstab || echo "UUID=$UUID $MNT ext4 defaults,noatime 0 2" >> /etc/fstab
systemctl daemon-reload
mountpoint -q "$MNT" || mount "$MNT"
grep -q "^dir: $STORAGE$" /etc/pve/storage.cfg || pvesm add dir "$STORAGE" --path "$MNT" --content images
pvesm status --storage "$STORAGE"
findmnt "$MNT"
```

```bash
more /etc/pve/storage.cfg
pvesm set local --content iso,vztmpl,backup,import,snippets
ls -la /var/lib/vz

cat > /var/lib/vz/snippets/cloud-config-vendor-qemu-guest-agent.yaml <<'EOF'
#cloud-config
package_update: true
packages:
  - qemu-guest-agent
runcmd:
  - [ systemctl, enable, --now, qemu-guest-agent ]
EOF
```

```bash
qm agent 224 ping
qm agent 224 network-get-interfaces
```