### test-vm-nfs

```bash
qm clone 9001 211 --name test-vm-nfs --full 1

qm resize 211 scsi0 16G

qm set 211 \
  --scsi2 local-lvm:cloudinit \
  --ipconfig0 ip=192.168.178.211/24,gw=192.168.178.1 \
  --nameserver 192.168.178.201 \
  --ciuser ubuntu \
  --sshkeys ~/.ssh/homelab-ed25519.pub \
  --onboot 1
  
qm start 211

ssh ubuntu@192.168.178.211
sudo apt update
sudo apt install -y qemu-guest-agent nfs-common

sudo systemctl enable --now qemu-guest-agent
systemctl status qemu-guest-agent

#
# test client setup
#

getent group 3001 >/dev/null || sudo groupadd -g 3001 test-vm-nfs
id -nG ubuntu | grep -qw test-vm-nfs || sudo usermod -aG test-vm-nfs ubuntu

sudo mkdir -p /mnt/test-vm-nfs

grep -qE "^[^#].*\s/mnt/test-vm-nfs\s" /etc/fstab || echo "192.168.178.202:/test-vm-nfs /mnt/test-vm-nfs nfs nfsvers=4.2,_netdev,x-systemd.automount,nosuid,nodev,noexec,nofail 0 0" | sudo tee -a /etc/fstab

sudo systemctl daemon-reload
sudo systemctl restart remote-fs.target

groups ubuntu
findmnt -T /mnt/test-vm-nfs || echo "Will automount on first access"

sudo -u ubuntu -g test-vm-nfs touch /mnt/test-vm-nfs/test-file
ls -la /mnt/test-vm-nfs/test-file

ls -l /mnt/test-vm-nfs
findmnt -T /mnt/test-vm-nfs -o TARGET,SOURCE,FSTYPE,OPTIONS

dd if=/dev/zero of=/mnt/test-vm-nfs/test-4G.bin bs=1M count=4096 status=progress conv=fdatasync
ls -lh /mnt/test-vm-nfs/test-4G.bin
```