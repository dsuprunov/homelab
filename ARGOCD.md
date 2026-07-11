# Argo CD

## Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
```

## First Manual Sync

```bash
kubectl -n argocd get pods
kubectl -n argocd get app

kubectl -n argocd port-forward svc/argocd-server 8080:80

http://127.0.0.1:8080
```

Login as `admin` with the initial admin password, then sync:

```text
Applications -> root-app -> Sync
```

Watch the applications:

```bash
watch kubectl -n argocd get app
```

## Normal Access

After `cilium-gateway`, `cert-manager`, and the Argo CD application are healthy,
use the Gateway URL:

```text
https://argocd.k8s.home.arpa
```
