# Security Group for the Shared Services / Microservices
resource "aws_security_group" "additional_sg" {
  name        = "${var.cluster_name}-additional-sg"
  description = "Security group for microservice communication"
  vpc_id      = module.vpc.vpc_id

  # Inbound rule: Allow internal communication within the VPC (Best practice for K8s)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow all internal traffic within the VPC CIDR"
  }

  # Outbound rule: Allow all traffic to the internet (Required for NAT Gateway updates)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.cluster_name}-additional-sg"
    Environment = var.environment
    Terraform   = "true"
  }
}