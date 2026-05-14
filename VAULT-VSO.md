# Vault Secrets Operator

## 1. Prepare local Vault certificate

```bash
mkdir -p "$HOME/.config/vault/certs"

ssh debian@vm-vault-01.home.arpa "sudo cat /opt/vault/tls/tls.crt" > "$HOME/.config/vault/certs/vault.home.arpa.crt"
```

## 2. Configure local Vault client environment

```bash
export VAULT_ADDR="https://vault.home.arpa:8200"

export VAULT_CACERT="$HOME/.config/vault/certs/vault.home.arpa.crt"

vault version

vault status
```

## 3. Load an admin token

```bash
export VAULT_TOKEN="<vault_admin_token>"

# Confirm that the current token is valid and loaded in the environment.
vault token lookup
```

## 4. Verify VSO and base mounts

```bash
kubectl -n vault-secrets-operator get pods

kubectl get crd | grep 'secrets.hashicorp.com'

vault status

# Check whether the kubernetes auth method already exists.
vault auth list

# Ensure the shared kv-v2 mount exists at secret/.
vault secrets list | grep '^secret/' || vault secrets enable -path=secret kv-v2

# Show the final list of enabled secrets engines.
vault secrets list
```

## 5. Create a dedicated Kubernetes token reviewer

```bash
kubectl create namespace vault-secrets-operator --dry-run=client -o yaml | kubectl apply -f -

# Create a service account that Vault will use for TokenReview calls.
kubectl -n vault-secrets-operator create serviceaccount vault-k8s-auth \
  --dry-run=client -o yaml | kubectl apply -f -

# Grant that service account permission to call the TokenReview API.
kubectl create clusterrolebinding vault-k8s-auth-delegator \
  --clusterrole=system:auth-delegator \
  --serviceaccount=vault-secrets-operator:vault-k8s-auth \
  --dry-run=client -o yaml | kubectl apply -f -

# Create a long-lived service account token Secret for Vault to use.
kubectl -n vault-secrets-operator apply -f - <<'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: vault-k8s-auth-token
  annotations:
    kubernetes.io/service-account.name: vault-k8s-auth
type: kubernetes.io/service-account-token
EOF
```

## 6. Capture Kubernetes auth inputs

```bash
# Read the reviewer JWT from the service account token Secret.
TOKEN_REVIEW_JWT="$(kubectl -n vault-secrets-operator get secret vault-k8s-auth-token -o go-template='{{ .data.token }}' | base64 -d)"

# Read the Kubernetes API CA certificate from the current kubeconfig.
KUBE_CA_CERT="$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 -d)"

# Use the Kubernetes API
KUBE_HOST="https://k8s-api.home.arpa:6443"

printf 'KUBE_HOST=%s\n' "$KUBE_HOST"
printf 'TOKEN_REVIEW_JWT length=%s\n' "${#TOKEN_REVIEW_JWT}"
printf 'KUBE_CA_CERT length=%s\n' "${#KUBE_CA_CERT}"
```

## 7. Enable and configure `auth/kubernetes`

```bash
# Enable the kubernetes auth method if it is not enabled yet.
vault auth list | grep '^kubernetes/' || vault auth enable kubernetes

# Configure Vault to validate Kubernetes service account tokens against the cluster API.
vault write auth/kubernetes/config \
  token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
  kubernetes_host="$KUBE_HOST" \
  kubernetes_ca_cert="$KUBE_CA_CERT"
```

## 8. Verify `auth/kubernetes`

```bash
# Confirm that the kubernetes auth method is enabled.
vault auth list | grep '^kubernetes/'

# Read back the full auth/kubernetes configuration.
vault read auth/kubernetes/config

# Check specifically that the configured API endpoint is the expected VIP.
vault read auth/kubernetes/config | grep 'kubernetes_host'
```
