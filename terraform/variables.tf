########################################
# VARIABLES FILE
########################################
# This file defines all the inputs Terraform expects.
# Think of these as "questions" Terraform asks.
# The answers go in terraform.tfvars.

########################################
# GENERAL SETTINGS
########################################

# AWS region to deploy resources into
variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
}

# Project name used for tagging and naming resources
variable "project_name" {
  description = "Project name used for naming and tagging"
  type        = string
}

# Environment name (dev, test, prod)
variable "environment" {
  description = "Environment name such as dev, test, or prod"
  type        = string
}

########################################
# EKS CLUSTER SETTINGS
########################################

# Name of the EKS cluster
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

# Kubernetes version for the EKS control plane
variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

########################################
# NETWORK (VPC) SETTINGS
########################################

# Main CIDR block for the VPC
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# CIDR blocks for public subnets (Jenkins, ALB later)
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

# CIDR blocks for private subnets (EKS worker nodes)
variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

########################################
# EKS NODE GROUP SETTINGS
########################################

# EC2 instance type for EKS worker nodes
variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
}

# Desired number of nodes when cluster starts
variable "node_desired_size" {
  description = "Desired node count for the EKS managed node group"
  type        = number
}

# Minimum number of nodes (always running)
variable "node_min_size" {
  description = "Minimum node count for the EKS managed node group"
  type        = number
}

# Maximum number of nodes (scaling limit)
variable "node_max_size" {
  description = "Maximum node count for the EKS managed node group"
  type        = number
}

########################################
# JENKINS SERVER SETTINGS
########################################

# EC2 instance type for Jenkins server
variable "jenkins_instance_type" {
  description = "EC2 instance type for the Jenkins server"
  type        = string
}

# Root disk size for Jenkins EC2 (important for builds)
variable "jenkins_volume_size" {
  description = "Root volume size in GiB for the Jenkins EC2 instance"
  type        = number
}

# AMI ID used to launch Jenkins EC2
variable "jenkins_ami_id" {
  description = "AMI ID for the Jenkins EC2 instance"
  type        = string
}

########################################
# ACCESS SETTINGS
########################################

# CIDR block allowed to access Jenkins (SSH + web)
variable "admin_cidr" {
  description = "CIDR block allowed to access Jenkins on ports 22 and 8080"
  type        = string
}

# AWS key pair name for SSH (NOT the .pem file)
variable "jenkins_key_name" {
  description = "AWS key pair name for Jenkins SSH access"
  type        = string
}

########################################
# ECR SETTINGS
########################################

# Name of the ECR repository
variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
}