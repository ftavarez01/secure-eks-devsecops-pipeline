module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Using private subnets for the control plane to ensure network isolation
  control_plane_subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  # Essential add-ons for cluster networking and storage persistence
  cluster_addons = {
    coredns            = { most_recent = true }
    kube-proxy         = { most_recent = true }
    vpc-cni            = { most_recent = true }
    aws-ebs-csi-driver = { most_recent = true } # Critical for Database Persistent Volumes (PVs)
  }

  # Security: Automatically grant the IAM creator admin permissions in K8s RBAC
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT" # Cost-optimization for Dev environments
    }
  }

  tags = {
    Environment = var.environment
    Project     = "Secure-EKS-DevSecOps"
    Terraform   = "true"
  }
}
