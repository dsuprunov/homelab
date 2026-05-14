```bash
kubectl -n demo-hashicorp-vso get vaultconnection,vaultauth,vaultstaticsecret
kubectl -n demo-hashicorp-vso get secret demo-hashicorp-vso-env-secret -o yaml
kubectl -n demo-hashicorp-vso exec -ti deploy/demo-hashicorp-vso -- printenv | grep '^DEMO_'
```
