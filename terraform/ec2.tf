########################################
# JENKINS EC2 SERVER
########################################
# This creates the Jenkins server where:
# - CI/CD pipelines will run
# - Docker images will be built
# - Deployments to EKS will happen

resource "aws_instance" "jenkins" {

  # AMI ID (pre-selected)
  ami = var.jenkins_ami_id

  # Instance size (you selected m7i-flex.large)
  instance_type = var.jenkins_instance_type

  # Place EC2 in a PUBLIC subnet so you can SSH into it
  subnet_id = aws_subnet.public[0].id

  # Attach Jenkins security group
  vpc_security_group_ids = [aws_security_group.jenkins.id]

  # Attach IAM role so Jenkins can access AWS services (ECR, EKS)
  iam_instance_profile = aws_iam_instance_profile.jenkins_profile.name

  # Give the instance a public IP
  associate_public_ip_address = true

  # Key pair for SSH access
  key_name = var.jenkins_key_name

  ########################################
  # SECURITY SETTINGS
  ########################################

  # Enforce IMDSv2 for better security
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  ########################################
  # STORAGE SETTINGS
  ########################################

  # Root volume configuration
  root_block_device {

    # Increase disk size to 30GB for Jenkins workloads
    volume_size = var.jenkins_volume_size

    volume_type = "gp3"

    # Encrypt the volume
    encrypted = true

    # Delete disk when instance is deleted
    delete_on_termination = true
  }

  ########################################
  # TAGS
  ########################################

  tags = merge(local.common_tags, {
    Name = "Jenkins Server Tech Challenge 2"
  })
}