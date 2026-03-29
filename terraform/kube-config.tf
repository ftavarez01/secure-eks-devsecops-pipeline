resource "null_resource" "configure_kubectl" {
  triggers = {
    cluster_id = module.eks.cluster_id
  }

  provisioner "local-exec" {
    command = var.kubeconfig
  }
}
