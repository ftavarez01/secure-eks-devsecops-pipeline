variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "devsecops-eks-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Deployment environment (dev/prod)"
  type        = string
  default     = "dev"
}                                       

variable "kubeconfig" {
  description = "Run this command to configure local kubectl access to the EKS cluster"
  type = string
  default = "aws eks update-kubeconfig --region us-east-1 --name devsecops-eks-cluster"
  
}