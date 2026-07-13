# Monitoring Operations

## Grafana admin credentials

Grafana reads the admin credentials from the manually managed
`grafana-admin-credentials` Secret. The Secret is intentionally not committed
to Git. On a new cluster, the `kube-prometheus-stack` application can remain
`Degraded` until the first sync creates the `monitoring` namespace and the
Secret is created manually. This initial `Degraded` status is expected.

Create the Grafana admin credentials Secret after the `monitoring` namespace
exists:

```bash
kubectl -n monitoring create secret generic grafana-admin-credentials \
  --from-literal=admin-user='admin' \
  --from-literal=admin-password='<YOUR-STRONG-STABLE-PASSWORD>' \
  --dry-run=client -o yaml \
  | kubectl apply -f -
```

Verify the stored password only when needed:

```bash
kubectl -n monitoring get secret grafana-admin-credentials \
  -o jsonpath='{.data.admin-password}' | base64 -d ; echo
```

The admin credentials are used only when Grafana initializes a new database.
After the persistent Grafana database has been created, updating this Secret
does not change the password of the existing Grafana admin user. Rotate an
existing admin password through Grafana or its admin CLI/API.
