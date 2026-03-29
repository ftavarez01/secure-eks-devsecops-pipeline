# 1. Private Repository Definition
resource "aws_ecr_repository" "app_repo" {
  name                 = "eks-armor-flow" # Your project/app name
  image_tag_mutability = "IMMUTABLE"      # Security: Prevents existing tags from being overwritten

  image_scanning_configuration {
    scan_on_push = true # Automated vulnerability scanning on every push
  }

  encryption_configuration {
    encryption_type = "AES256" # AWS Managed encryption (Secure & Cost-Free)
  }

  tags = {
    Environment = "Dev"
    Project     = "EKS-Armor-Flow"
  }
}

# 2. Lifecycle Policy (Cost Savings)
resource "aws_ecr_lifecycle_policy" "cleanup_policy" {
  repository = aws_ecr_repository.app_repo.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep only the 2 most recent images to stay within Free Tier limits"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 2
      }
      action = {
        type = "expire"
      }
    }]
  })
}

# 3. Output for the GitHub Actions Pipeline
output "ecr_repository_url" {
  value       = aws_ecr_repository.app_repo.repository_url
  description = "The URL of the ECR repository to be used in the CI/CD pipeline"
}