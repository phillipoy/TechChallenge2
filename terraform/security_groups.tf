########################################
# JENKINS SECURITY GROUP
########################################
# This controls who can access your Jenkins EC2 server.
# Think of this like a firewall.

resource "aws_security_group" "jenkins" {

  # Name of the security group
  name = "tech-challenge-2-jenkins-sg"

  # Description for clarity
  description = "Security group for Jenkins EC2 server"

  # Attach to your VPC
  vpc_id = aws_vpc.main.id

  ########################################
  # TAGS
  ########################################

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 Jenkins Security Group"
  })
}

########################################
# SSH ACCESS (PORT 22)
########################################
# Allows you to connect to the Jenkins server using SSH

resource "aws_vpc_security_group_ingress_rule" "jenkins_ssh" {

  # Apply rule to Jenkins security group
  security_group_id = aws_security_group.jenkins.id

  # Who can access (your IP recommended)
  cidr_ipv4 = var.admin_cidr

  # SSH uses port 22
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 Jenkins SSH Rule"
  })
}

########################################
# JENKINS WEB UI (PORT 8080)
########################################
# Allows access to Jenkins dashboard in browser

resource "aws_vpc_security_group_ingress_rule" "jenkins_web" {

  # Apply rule to Jenkins security group
  security_group_id = aws_security_group.jenkins.id

  # Who can access Jenkins UI
  cidr_ipv4 = var.admin_cidr

  # Jenkins runs on port 8080 by default
  from_port   = 8080
  to_port     = 8080
  ip_protocol = "tcp"

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 Jenkins Web Rule"
  })
}

########################################
# OUTBOUND TRAFFIC (ALL)
########################################
# Allows Jenkins to talk to:
# - AWS (ECR, EKS)
# - internet (downloads, updates)

resource "aws_vpc_security_group_egress_rule" "jenkins_all_outbound" {

  # Apply rule to Jenkins security group
  security_group_id = aws_security_group.jenkins.id

  # Allow all destinations
  cidr_ipv4 = "0.0.0.0/0"

  # Allow all ports and protocols
  ip_protocol = "-1"

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 Jenkins Egress Rule"
  })
}