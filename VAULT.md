### pve (proxmox host)

1) Create a folder for VM persistent data
```bash
mkdir -p /mnt/pve/pve-data/vm-vault-01
chmod 777 /mnt/pve/pve-data/vm-vault-01
ls -ld /mnt/pve/pve-data/vm-vault-01
```

2) Create a Directory Mapping (if it does not exist yet)
```bash
pvesh create /cluster/mapping/dir \
  --id vm-vault-01 \
  --map node=pve,path=/mnt/pve/pve-data/vm-vault-01
```

3) Connect VirtioFS to the VM
```bash
qm shutdown 206
qm set 206 -virtiofs0 dirid=vm-vault-01,cache=auto
qm config 206 | grep -i virtiofs
qm start 206
qm status 206
```

### vm-vault-01 (vault virtual machine)

4) Install HashiCorp Vault
```bash
sudo apt update
sudo apt install -y gpg rsync

curl -fsSL https://apt.releases.hashicorp.com/gpg \
  | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install -y vault

sudo -u vault openssl req -x509 -newkey rsa:4096 -nodes -sha256 -days 3650 \
  -subj "/CN=vault.home.arpa" \
  -addext "subjectAltName=DNS:vault.home.arpa" \
  -keyout /opt/vault/tls/tls.key \
  -out /opt/vault/tls/tls.crt

cat <<'EOF' | sudo tee /etc/vault.d/vault.hcl >/dev/null
ui = true
disable_mlock = true

storage "file" {
  path = "/opt/vault/data"
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/opt/vault/tls/tls.crt"
  tls_key_file  = "/opt/vault/tls/tls.key"
}

api_addr = "https://vault.home.arpa:8200"
EOF

sudo systemctl enable vault
```

5) Mount VirtioFS
```bash
sudo mkdir -p /mnt/vm-vault-01
sudo mount -t virtiofs vm-vault-01 /mnt/vm-vault-01
mount | grep vm-vault-01
```

6) Enable auto-mount (systemd automount)
```bash
echo 'vm-vault-01 /mnt/vm-vault-01 virtiofs nofail,x-systemd.automount 0 0' | sudo tee -a /etc/fstab
sudo systemctl daemon-reload
sudo umount /mnt/vm-vault-01
sudo mount -a
mount | grep vm-vault-01
```

7) Move `/opt/vault/data` to VirtioFS and replace it with a symlink
```bash
sudo systemctl stop vault

sudo rsync --archive --relative /opt/vault/data/ /mnt/vm-vault-01/
sudo rm -fr /opt/vault/data
sudo ln -s /mnt/vm-vault-01/opt/vault/data /opt/vault/data
ls -ld /opt/vault/data

sudo systemctl start vault
systemctl status vault --no-pager

curl --insecure https://vault.home.arpa:8200/v1/sys/health
```

8) Initialize, Unseal, and Verify Vault
```bash
sudo -i

export VAULT_ADDR="https://vault.home.arpa:8200"
export VAULT_CACERT="/opt/vault/tls/tls.crt"

vault status

vault operator init -key-shares=1 -key-threshold=1 | tee /opt/vault/data/vault-init.txt
chmod 600 /opt/vault/data/vault-init.txt

UNSEAL_KEY=$(grep -m1 '^Unseal Key 1:' /opt/vault/data/vault-init.txt | awk '{print $4}')
ROOT_TOKEN=$(grep -m1 '^Initial Root Token:' /opt/vault/data/vault-init.txt | awk '{print $4}')

vault operator unseal "$UNSEAL_KEY"
vault status

vault login "$ROOT_TOKEN"
vault secrets enable -path=secret kv-v2
vault secrets list

vault kv put secret/vault-smoke-test status="ok" owner="vm-vault-01"
vault kv get secret/vault-smoke-test
vault kv metadata get secret/vault-smoke-test
vault kv delete secret/vault-smoke-test
vault kv get secret/vault-smoke-test
``` 
