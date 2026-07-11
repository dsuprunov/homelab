# Argo CD

## Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
```

## First Manual Sync

```bash
kubectl -n argocd get app

kubectl -n argocd port-forward svc/argocd-server 8080:443

https://localhost:8080

Applications -> root-app -> Sync
```
