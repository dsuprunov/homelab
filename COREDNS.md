### pve (proxmox host)

1) Create a folder for VM persistent data
```bash
mkdir -p /mnt/pve/pve-data/vm-coredns-01/etc/coredns
chmod 777 /mnt/pve/pve-data/vm-coredns-01
ls -ld /mnt/pve/pve-data/vm-coredns-01
```

2) Create a Directory Mapping for VirtioFS (if it does not exist yet)
```bash
pvesh create /cluster/mapping/dir \
  --id vm-coredns-01 \
  --map node=pve,path=/mnt/pve/pve-data/vm-coredns-01
```

### vm-coredns-01 (debian virtual machine)

3) Mount VirtioFS in VM
```bash
sudo mkdir -p /mnt/vm-coredns-01
sudo mount -t virtiofs vm-coredns-01 /mnt/vm-coredns-01
mount | grep vm-coredns-01
```

4) Enable auto-mount
```bash
echo 'vm-coredns-01 /mnt/vm-coredns-01 virtiofs nofail,x-systemd.automount 0 0' | sudo tee -a /etc/fstab
sudo systemctl daemon-reload
sudo umount /mnt/vm-coredns-01
sudo mount -a
mount | grep vm-coredns-01
```

5) Install CoreDNS binary
```bash
sudo apt update
sudo apt install -y curl dnsutils

sudo curl -fL https://github.com/coredns/coredns/releases/download/v1.14.2/coredns_1.14.2_linux_amd64.tgz -o /tmp/coredns.tgz
sudo tar -xzf /tmp/coredns.tgz -C /tmp
sudo install -m 0755 /tmp/coredns /usr/local/bin/coredns
/usr/local/bin/coredns -version
sudo rm -f /tmp/coredns /tmp/coredns.tgz
```

6) Store CoreDNS config on host-backed path
```bash
cat <<'EOF' | sudo tee /mnt/vm-coredns-01/etc/coredns/Corefile >/dev/null
.:53 {
    errors
    log
    health
    ready
    
    file /etc/coredns/home.arpa.zone home.arpa {
        reload 1m
    }
    
    forward . 8.8.8.8 1.1.1.1
    cache 300
    reload
}
EOF

cat <<'EOF' | sudo tee /mnt/vm-coredns-01/etc/coredns/home.arpa.zone >/dev/null
$ORIGIN home.arpa.
$TTL 300
@       IN SOA  ns.home.arpa. admin.home.arpa. (
                2026030601 ; serial
                3600       ; refresh
                600        ; retry
                604800     ; expire
                300        ; minimum
)
        IN NS   ns.home.arpa.
ns      IN A    192.168.178.205
EOF
```

7) Disable `systemd-resolved` DNS stub on `:53`
```bash
sudo ss -luntp | grep ':53'
sudo mkdir -p /etc/systemd/resolved.conf.d
cat <<'EOF' | sudo tee /etc/systemd/resolved.conf.d/disable-stub.conf >/dev/null
[Resolve]
DNSStubListener=no
EOF
sudo systemctl restart systemd-resolved
sudo ss -luntp | grep ':53'
```

8) Link `/etc/coredns` to host-backed path and start service
```bash
sudo rm -rf /etc/coredns
sudo ln -s /mnt/vm-coredns-01/etc/coredns /etc/coredns
ls -ld /etc/coredns

cat <<'EOF' | sudo tee /etc/systemd/system/coredns.service >/dev/null
[Unit]
Description=CoreDNS DNS server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/coredns -conf /etc/coredns/Corefile
Restart=on-failure
RestartSec=2s

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now coredns
sudo systemctl status coredns --no-pager
sudo ss -luntp | grep ':53'
```
### zone updates

9) Edit zone file
```bash
sudo nano /mnt/vm-coredns-01/etc/coredns/home.arpa.zone
```

11) Update SOA serial after each change
```text
@ IN SOA ns.home.arpa. admin.home.arpa. (YYYYMMDDNN ...)
```
Example: `2026030602`, `2026030603`, ...

12) Apply changes
```bash
sudo systemctl restart coredns
sudo systemctl status coredns --no-pager
```
