# TODO

## Argo CD AppProject Permissions

- Review wildcard project permissions and destinations:

  ```yaml
  destinations:
    - server: https://kubernetes.default.svc
      namespace: "*"
  clusterResourceWhitelist:
    - group: "*"
      kind: "*"
  namespaceResourceWhitelist:
    - group: "*"
      kind: "*"
  ```

  Current state is kept for bootstrap. Replace broad whitelists with explicit
  destinations and resource allowlists per platform project after the initial
  GitOps transfer is validated.

## Cilium Secrets Namespace

- Review `cilium-secrets` ownership and lifecycle.

  Current state is kept as Cilium chart-managed behavior. Confirm how Cilium
  Gateway API secrets sync uses this namespace and document whether it needs
  any GitOps policy, labels, or exclusions.
