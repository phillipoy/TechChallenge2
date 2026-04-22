########################################
# TERRAFORM + PROVIDER CONFIG
########################################
# This defines:
# - Terraform version
# - AWS provider
# - Default tags applied to all resources

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Default tags automatically added to all AWS resources
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Challenge   = "Tech Challenge 2"
    }
  }
}