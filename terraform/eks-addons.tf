# 1. Obtener la política oficial de Amazon para EBS
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# 2. Crear el Rol de IAM para el Driver
module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name             = "ebs-csi-irsa"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

# 3. Configurar el Add-on de EKS con el Rol vinculado
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.56.0-eksbuild.1" # La versión que acabas de confirmar
  service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn

  # Este parámetro es CLAVE para corregir el estado actual si ya existe
  resolve_conflicts_on_update = "OVERWRITE"
}