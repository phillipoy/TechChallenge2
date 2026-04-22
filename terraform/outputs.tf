########################################
# OUTPUTS
########################################
# These values are printed after Terraform runs.
# Helps you quickly find important info.

# VPC ID
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

# Public subnet IDs
output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

# Private subnet IDs
output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

# EKS cluster name
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

# Jenkins public IP
output "jenkins_public_ip" {
  description = "Public IP of Jenkins server"
  value       = aws_instance.jenkins.public_ip
}

# Jenkins URL
output "jenkins_url" {
  description = "Jenkins web UI"
  value       = "http://${aws_instance.jenkins.public_dns}:8080"
}

# ECR repository URL
output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.app.repository_url
}