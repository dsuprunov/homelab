```bash
sudo sgdisk -n 1:1MiB:0 -t 1:8300 -c 1:nas-data /dev/sdb && \
  sudo partx -u /dev/sdb && \
  sudo udevadm settle && \
  lsblk -o NAME,SIZE,TYPE,FSTYPE,PARTLABEL,MOUNTPOINTS /dev/sdb

sudo mkfs.ext4 -L nas-data /dev/sdb1

sudo install -d -m 0755 /srv/nfs/data

UUID="$(sudo blkid -s UUID -o value /dev/sdb1)"; \
  grep -q ' /srv/nfs/data ' /etc/fstab || \
  echo "UUID=$UUID /srv/nfs/data ext4 defaults,noatime 0 2" | sudo tee -a /etc/fstab; \
  grep ' /srv/nfs/data ' /etc/fstab

sudo mountpoint -q /srv/nfs/data || sudo mount /srv/nfs/data; findmnt /srv/nfs/data

sudo systemctl daemon-reload

grep -qE '^/srv/nfs/data 192\.168\.178\.0/24\(rw,sync,no_subtree_check\)$' /etc/exports || \
  echo '/srv/nfs/data 192.168.178.0/24(rw,sync,no_subtree_check)' | sudo tee -a /etc/exports; grep '/srv/nfs/data' /etc/exports
  
sudo exportfs -ra && sudo exportfs -v

showmount -e localhost
```

```bash
sudo apt-get update
sudo apt-get install -y nfs-common
sudo mkdir -p /mnt/nas-test
sudo mount -t nfs 192.168.178.206:/srv/nfs/data /mnt/nas-test
echo "hello from $(hostname) $(date -Is)" | sudo tee /mnt/nas-test/client-test.txt
cat /mnt/nas-test/client-test.txt
ls -lah /mnt/nas-test
```