```bash
kubectl create namespace dummy-portal

cat <<'EOF' | sudo tee dummy-portal.yaml >/dev/null
...
EOF

kubectl apply --dry-run=server -f dummy-portal.yaml
kubectl apply -f dummy-portal.yaml
```