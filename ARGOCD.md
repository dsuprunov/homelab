# Argo CD

## Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
```

## First Manual Sync

```bash
kubectl -n argocd get pods
kubectl -n argocd get apps
kubectl -n argocd get appprojects

kubectl -n argocd patch application root-app --type merge -p '{"operation":{"sync":{}}}'

watch kubectl -n argocd get app

kubectl -n argocd get app root-app
kubectl -n argocd describe app root-app
```

## Browser Access During Bootstrap

Use port-forward only when you want to inspect Argo CD in the browser before
normal Gateway access is ready:

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:80

http://127.0.0.1:8080
```

## Normal Access

After `cilium-gateway`, `cert-manager`, and the Argo CD application are healthy,
use the Gateway URL:

```text
https://argocd.k8s.home.arpa
```
