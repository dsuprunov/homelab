output "talosconfig" {
  description = "Talos client configuration for talosctl."
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubernetes client configuration."
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}

output "nodes" {
  description = "Talos node static addresses by role."

  value = {
    control_plane = local.control_static_ipv4
    worker        = local.worker_static_ipv4
  }
}
