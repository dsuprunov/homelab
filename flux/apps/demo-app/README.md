```bash
kubectl -n demo-app create secret generic demo-env-secret \
  --from-literal=DEMO_ENV_SECRET_LOGIN=my-env-login \
  --from-literal=DEMO_ENV_SECRET_PASSWORD=my-env-password

kubectl -n demo-app create secret generic demo-file-secret \
  --from-literal=DEMO_FILE_SECRET_LOGIN=my-file-login \
  --from-literal=DEMO_FILE_SECRET_PASSWORD=my-file-password
```

```bash
kubectl -n demo-app exec -ti deploy/demo-app -- printenv

kubectl -n demo-app exec -ti deploy/demo-app -- sh -c "ls -la /var/run/secrets/demo-app/"
kubectl -n demo-app exec -ti deploy/demo-app -- sh -c "ls -la /var/run/secrets/demo-app/demo-file-secret/"
kubectl -n demo-app exec -ti deploy/demo-app -- sh -c "cat /var/run/secrets/demo-app/demo-file-secret/DEMO_FILE_SECRET_LOGIN; echo"
kubectl -n demo-app exec -ti deploy/demo-app -- sh -c "cat /var/run/secrets/demo-app/demo-file-secret/DEMO_FILE_SECRET_PASSWORD; echo"
```
