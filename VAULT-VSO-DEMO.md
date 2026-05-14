# Vault VSO Demo

## 1. Load Vault environment

```bash
export VAULT_ADDR="https://vault.home.arpa:8200"
export VAULT_CACERT="$HOME/.config/vault/certs/vault.home.arpa.crt"
export VAULT_TOKEN="<vault_admin_token>"

vault token lookup
```

## 2. Create the policy

```bash
cat > /tmp/demo-hashicorp-vso-policy.hcl <<'EOF'
path "secret/data/demo-hashicorp-vso/*" {
  capabilities = ["read"]
}

path "secret/metadata/demo-hashicorp-vso/*" {
  capabilities = ["read", "list"]
}
EOF

vault policy write demo-hashicorp-vso /tmp/demo-hashicorp-vso-policy.hcl
vault policy read demo-hashicorp-vso
```

## 3. Create the Kubernetes auth role

```bash
vault write auth/kubernetes/role/demo-hashicorp-vso \
  bound_service_account_names="demo-hashicorp-vso" \
  bound_service_account_namespaces="demo-hashicorp-vso" \
  policies="demo-hashicorp-vso" \
  audience="vault" \
  ttl="1h"

vault read auth/kubernetes/role/demo-hashicorp-vso
```

## 4. Create the test secret

```bash
vault kv put secret/demo-hashicorp-vso/env \
  DEMO_ENV_SECRET_LOGIN="vso-env-login" \
  DEMO_ENV_SECRET_PASSWORD="vso-env-password"
```

## 5. Verify policy inputs

```bash
vault kv get secret/demo-hashicorp-vso/env

vault read auth/kubernetes/role/demo-hashicorp-vso
vault policy read demo-hashicorp-vso
```
