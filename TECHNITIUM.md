### pve (proxmox host)

1) Create a folder for VM persistent data
```bash
mkdir -p /mnt/pve/pve-data/vm-technitium-01
chmod 777 /mnt/pve/pve-data/vm-technitium-01
ls -ld /mnt/pve/pve-data/vm-technitium-01
```

2) Create a Directory Mapping (if it does not exist yet)
```bash
pvesh create /cluster/mapping/dir \
  --id vm-technitium-01 \
  --map node=pve,path=/mnt/pve/pve-data/vm-technitium-01
```

3) Connect VirtioFS to the VM
```bash
qm shutdown 205
qm set 205 -virtiofs0 dirid=vm-technitium-01,cache=auto
qm config 205 | grep -i virtiofs
qm start 205
qm status 205
```

### vm-technitium-01 (technitium virtual machine)

4) Install Technitium DNS Server
```bash
sudo apt update
sudo apt install -y rsync

curl -sSL https://download.technitium.com/dns/install.sh | sudo bash
sudo systemctl status dns --no-pager
```

5) Mount VirtioFS
```bash
sudo mkdir -p /mnt/vm-technitium-01
sudo mount -t virtiofs vm-technitium-01 /mnt/vm-technitium-01
mount | grep vm-technitium-01
```

6) Enable auto-mount (systemd automount)
```bash
echo 'vm-technitium-01 /mnt/vm-technitium-01 virtiofs nofail,x-systemd.automount 0 0' | sudo tee -a /etc/fstab
sudo systemctl daemon-reload
sudo umount /mnt/vm-technitium-01
sudo mount -a
mount | grep vm-technitium-01
```

7) Move `/etc/dns` to VirtioFS and replace it with a symlink
```bash
sudo systemctl stop dns

sudo rsync --archive --relative /etc/dns/ /mnt/vm-technitium-01/
sudo rm -fr /etc/dns
sudo ln -s /mnt/vm-technitium-01/etc/dns /etc/dns
ls -ld /etc/dns

sudo systemctl start dns
systemctl status dns --no-pager
```
