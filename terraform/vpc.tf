module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  # Availability Zones for High Availability
  azs = ["us-east-1a", "us-east-1b"]

  # Network Segmentation: Private subnets for Worker Nodes, Public for Load Balancers
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  # NAT Gateway configuration for private instances to access the internet
  enable_nat_gateway = true
  single_nat_gateway = true # Cost-saving measure for development environments

  # Required tags for EKS to correctly identify subnets for Load Balancers
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  # Resource Metadata
  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}
