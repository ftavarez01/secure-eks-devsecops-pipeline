output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}
output "kubeconfig_status" {
  value       = "Local kubectl has been automatically configured for devsecops-eks-cluster"
  description = "Confirmation message"
}
output "verify_nodes_command" {
  value       = "kubectl get nodes"
  description = "Run this to verify your 2 nodes are Ready"
}