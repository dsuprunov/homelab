1) Install CoreDNS binary
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
sudo install -d -o root -g root -m 0755 /etc/coredns
sudo install -o root -g root -m 0644 /dev/stdin /etc/coredns/Corefile <<'EOF'
.:53 {
    errors
    log
    health
    ready

    file /etc/coredns/home.arpa.zone home.arpa {
        reload 1m
    }
    
    file /etc/coredns/178.168.192.in-addr.arpa.zone 178.168.192.in-addr.arpa {
        reload 1m
    }

    forward . 8.8.8.8 1.1.1.1
    cache 300
    reload
}
EOF
sudo install -o root -g root -m 0644 /dev/stdin /etc/coredns/home.arpa.zone <<'EOF'
$ORIGIN home.arpa.
$TTL 300
@       IN SOA  ns.home.arpa. admin.home.arpa. (
                2026050701 ; serial
                3600       ; refresh
                600        ; retry
                604800     ; expire
                300        ; minimum
)
        IN NS   ns.home.arpa.
        
ns                  IN A  192.168.178.206

vm-coredns          IN A  192.168.178.206

k8s-api             IN A  192.168.178.230
vm-k8s-control-01   IN A  192.168.178.231
vm-k8s-worker-01    IN A  192.168.178.236
vm-k8s-worker-02    IN A  192.168.178.237
vm-k8s-worker-03    IN A  192.168.178.238

grafana.k8s         IN A  192.168.178.246
dummy-portal.k8s    IN A  192.168.178.246
EOF
sudo install -o root -g root -m 0644 /dev/stdin /etc/coredns/178.168.192.in-addr.arpa.zone <<'EOF'
$ORIGIN 178.168.192.in-addr.arpa.
$TTL 300
@       IN SOA  ns.home.arpa. admin.home.arpa. (
                2026050701 ; serial
                3600       ; refresh
                600        ; retry
                604800     ; expire
                300        ; minimum
)
        IN NS   ns.home.arpa.

206     IN PTR  vm-coredns.home.arpa.

230     IN PTR  k8s-api.home.arpa.
231     IN PTR  vm-k8s-control-01.home.arpa.
236     IN PTR  vm-k8s-worker-01.home.arpa.
237     IN PTR  vm-k8s-worker-02.home.arpa.
238     IN PTR  vm-k8s-worker-03.home.arpa.
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
sudo nano /etc/coredns/home.arpa.zone
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
