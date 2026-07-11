# Argo CD

## Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
```

## First Manual Sync

### CLI

```bash
tmux new-session -d -s argocd \
  'kubectl -n argocd port-forward svc/argocd-server 8080:443' \; \
  split-window -h \; \
  attach-session

argocd login localhost:8080 --username admin --password "$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)" --insecure
argocd app get root-app
argocd app sync root-app

kubectl -n argocd get app
kubectl -n argocd get appprojects
```

### Browser

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:443

https://localhost:8080

Applications -> root-app -> Sync
```
