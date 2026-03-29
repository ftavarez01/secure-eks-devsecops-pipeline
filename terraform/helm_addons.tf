data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(
      module.eks.cluster_certificate_authority_data
    )
    token = data.aws_eks_cluster_auth.this.token
  }
}

resource "helm_release" "falco" {
  depends_on = [module.eks]

  name             = "falco"
  repository       = "https://falcosecurity.github.io/charts"
  chart            = "falco"
  namespace        = "falco"
  create_namespace = true

  set = [
    {
      name  = "driver.kind"
      value = "ebpf"
    },
    {
      name  = "tty"
      value = "true"
    },
    {
      name  = "falco.jsonOutput"
      value = "true"
    }
  ]
}