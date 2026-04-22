########################################
# ECR (DOCKER IMAGE STORAGE)
########################################
# This creates a repository where Docker images will be stored.
# Jenkins will push images here before deploying to EKS.

resource "aws_ecr_repository" "app" {

  # Name of the repository
  name = var.ecr_repository_name

  # Allows overwriting tags like "latest"
  image_tag_mutability = "MUTABLE"

  # Scan images for vulnerabilities when pushed
  image_scanning_configuration {
    scan_on_push = true
  }

  # Encrypt images using AWS-managed encryption
  encryption_configuration {
    encryption_type = "AES256"
  }

  # Tags for identification
  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 ECR Repository"
  })
}