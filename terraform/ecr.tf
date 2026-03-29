# Private Repository Definition
resource "aws_ecr_repository" "app_repo" {
  name                 = "eks-armor-flow" # Application Name (Microservice)
  image_tag_mutability = "IMMUTABLE"     # Security: Prevents existing tags from being overwritten

  image_scanning_configuration {
    scan_on_push = true # Automatically scans for vulnerabilities upon image upload
  }

  encryption_configuration {
    encryption_type = "KMS" # Encryption at rest for maximum security
  }
}

# Lifecycle Policy to keep ECR clean and within Free Tier 
resource "aws_ecr_lifecycle_policy" "cleanup_policy" {
  repository = aws_ecr_repository.app_repo.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep only the 2 most recent images to optimize costs"
      selection = {
        tagStatus     = "any"
        countType     = "imageCountMoreThan"
        countNumber   = 2
      }
      action = {
        type = "expire"
      }
    }]
  })
}

# Output for use in the GitHub Actions pipeline
output "ecr_repository_url" {
  value       = aws_ecr_repository.app_repo.repository_url
  description = "The URL of the ECR repository"
}