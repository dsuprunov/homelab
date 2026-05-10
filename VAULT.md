# Vault Operations

## Web UI

Vault Web UI: `https://vault.home.arpa:8200/ui/`

## Environment

```bash
sudo -i

export VAULT_ADDR="https://vault.home.arpa:8200"
export VAULT_CACERT="/opt/vault/tls/tls.crt"
```

## Initialize

```bash
vault status

vault operator init -key-shares=1 -key-threshold=1 | tee /opt/vault/data/vault-init.txt
chmod 600 /opt/vault/data/vault-init.txt
```

## Unseal

```bash
UNSEAL_KEY=$(grep -m1 '^Unseal Key 1:' /opt/vault/data/vault-init.txt | awk '{print $4}')

vault operator unseal "$UNSEAL_KEY"
vault status
```

## Seal

```bash
ROOT_TOKEN=$(grep -m1 '^Initial Root Token:' /opt/vault/data/vault-init.txt | awk '{print $4}')
vault login "$ROOT_TOKEN"

vault operator seal
vault status
```

## Smoke Test

```bash
ROOT_TOKEN=$(grep -m1 '^Initial Root Token:' /opt/vault/data/vault-init.txt | awk '{print $4}')

vault login "$ROOT_TOKEN"
vault secrets enable -path=secret kv-v2
vault secrets list

vault kv put secret/vault-smoke-test status="ok" owner="vm-vault-01"
vault kv get secret/vault-smoke-test
vault kv metadata get secret/vault-smoke-test
vault kv delete secret/vault-smoke-test
vault kv get secret/vault-smoke-test
```
