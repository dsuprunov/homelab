```bash
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9 homelab' >> /root/.ssh/authorized_keys
```

```bash
pveum user token add root@pam terraform --privsep 0
```

```bash
NODE=$(hostname)

pvesh get /nodes/$NODE/network

pvesh set /nodes/$NODE/network/vmbr0 --type bridge --comments WAN

pvesh create /nodes/$NODE/network \
  --iface vmbr1 \
  --type bridge \
  --autostart 1 \
  --comments LAN
pvesh set /nodes/$NODE/network

pvesh get /nodes/$NODE/network
```

```bash
more /etc/pve/storage.cfg
pvesm set local --content iso,vztmpl,backup,import,snippets

cat > /var/lib/vz/snippets/cloud-config-vendor-qemu-guest-agent.yaml <<'EOF'
#cloud-config
package_update: true
packages:
  - qemu-guest-agent
runcmd:
  - [ systemctl, enable, --now, qemu-guest-agent ]
EOF
```