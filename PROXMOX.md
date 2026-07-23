```bash
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9 homelab' >> /root/.ssh/authorized_keys
```

```bash
pvesm status
more /etc/pve/storage.cfg

pvesm remove local-lvm

lvremove -y /dev/pve/data
lvextend -l +100%FREE -r /dev/pve/root

lsblk -d -o NAME,SIZE,MODEL,SERIAL

TARGET=/dev/nvme1n1

lsblk -f "$TARGET"

sgdisk --zap-all "$TARGET"
wipefs -af "$TARGET"

sgdisk -n1:0:0 -t1:8e00 -c1:"vmdata" "$TARGET"

blockdev --rereadpt "$TARGET"
udevadm settle
sync

lsblk -f "$TARGET"

pvcreate -ff -y "${TARGET}p1"
vgcreate vmdata "${TARGET}p1"

lvcreate --type thin-pool \
  -n data \
  -l 99%VG \
  --discards passdown \
  vmdata

pvesm add lvmthin local-lvm \
  --vgname vmdata \
  --thinpool data \
  --content images,rootdir

pvesm status
more /etc/pve/storage.cfg
lsblk -f -o NAME,SIZE,MODEL,SERIAL
```

```bash
pveum user token add root@pam terraform --privsep 0
```
