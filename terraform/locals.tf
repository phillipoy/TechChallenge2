########################################
# LOCALS FILE
########################################
# This file is used to store reusable values.
# It helps avoid repeating the same code over and over.

locals {

  # Prefix used for naming resources consistently
  name_prefix = "tech-challenge-2"

  # Common tags applied to all resources
  # Helps identify resources easily in AWS console
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Challenge   = "Tech Challenge 2"
  }
}