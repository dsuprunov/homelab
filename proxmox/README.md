```bash
pveum user token add root@pam terraform --privsep 0

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