### pve (proxmox host)

1) Create a folder for VM persistent data
```bash
mkdir -p /mnt/pve/pve-data/vm-vault
chmod 777 /mnt/pve/pve-data/vm-vault
ls -ld /mnt/pve/pve-data/vm-vault
```

2) Create a Directory Mapping (if it does not exist yet)
```bash
pvesh create /cluster/mapping/dir \
  --id vm-vault \
  --map node=pve,path=/mnt/pve/pve-data/vm-vault
```

3) Connect VirtioFS to the VM
```bash
qm shutdown 202
qm set 202 -virtiofs0 dirid=vm-vault,cache=auto
qm config 202 | grep -i virtiofs
qm start 202
qm status 202
```

### vm-vault (vault virtual machine)

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
sudo mkdir -p /mnt/vm-vault
sudo mount -t virtiofs vm-vault /mnt/vm-vault
mount | grep vm-vault
```

6) Enable auto-mount (systemd automount)
```bash
echo 'vm-vault /mnt/vm-vault virtiofs nofail,x-systemd.automount 0 0' | sudo tee -a /etc/fstab
sudo systemctl daemon-reload
sudo umount /mnt/vm-vault
sudo mount -a
mount | grep vm-vault
```

7) Replace `/opt/vault/data` with a symlink to `/mnt/vm-vault/opt/vault/data`
```bash
sudo systemctl stop vault

sudo install -d -o vault -g vault -m 750 /mnt/vm-vault/opt/vault/data
sudo rsync -a /opt/vault/data/ /mnt/vm-vault/opt/vault/data/
sudo rm -rf /opt/vault/data

sudo ln -s /mnt/vm-vault/opt/vault/data /opt/vault/data
ls -ld /opt/vault/data
```

8) Initialize, Unseal, and Verify Vault
```bash
sudo -i

systemctl start vault
systemctl status vault --no-pager

export VAULT_ADDR="https://vault.home.arpa:8200"
export VAULT_CACERT="/opt/vault/tls/tls.crt"

vault status

vault operator init -key-shares=1 -key-threshold=1 | tee /opt/vault/data/vault-init.txt
chmod 600 /opt/vault/data/vault-init.txt

UNSEAL_KEY=$(grep -m1 '^Unseal Key 1:' /opt/vault/data/vault-init.txt | awk '{print $4}')
ROOT_TOKEN=$(grep -m1 '^Initial Root Token:' /opt/vault/data/vault-init.txt | awk '{print $4}')

vault operator unseal "$UNSEAL_KEY"
vault login "$ROOT_TOKEN"
vault status

vault secrets list

vault secrets enable -path=secret kv-v2
vault kv put secret/lab hello="world" owner="vm-vault"
vault kv get secret/lab
``` 
