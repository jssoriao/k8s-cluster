output "cluster_id" {
  description = "Cluster Identifier"
  value       = linode_lke_cluster.default_cluster.id
}

output "api_endpoints" {
  description = "The endpoints for the Kubernetes API server"
  value       = linode_lke_cluster.default_cluster.api_endpoints
}

output "kubeconfig" {
  description = "Base64 encoded kubeconfig"
  value       = linode_lke_cluster.default_cluster.kubeconfig
  sensitive   = true
}
