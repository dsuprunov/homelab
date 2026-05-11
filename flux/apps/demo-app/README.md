```bash
kubectl -n demo-app exec -ti deploy/demo-app -- printenv

kubectl -n demo-app exec -ti deploy/demo-app -- sh -c "ls -la /var/run/secrets/demo-app/"
kubectl -n demo-app exec -ti deploy/demo-app -- sh -c "ls -la /var/run/secrets/demo-app/demo-file-secret/"
kubectl -n demo-app exec -ti deploy/demo-app -- sh -c "cat /var/run/secrets/demo-app/demo-file-secret/DEMO_FILE_SECRET_LOGIN; echo"
kubectl -n demo-app exec -ti deploy/demo-app -- sh -c "cat /var/run/secrets/demo-app/demo-file-secret/DEMO_FILE_SECRET_PASSWORD; echo"
```
