########################################
# EKS CLUSTER (CONTROL PLANE)
########################################
# This creates the main Kubernetes control plane.
# Think of this as the "brain" of Kubernetes.

resource "aws_eks_cluster" "main" {

  # Name of the cluster
  name = var.cluster_name

  # IAM role that gives EKS permission to manage AWS resources
  role_arn = aws_iam_role.eks_cluster_role.arn

  # Kubernetes version
  version = var.cluster_version

  ########################################
  # ACCESS CONFIG
  ########################################
  # This controls how users (like Jenkins) access the cluster

  access_config {

    # Use AWS API instead of old aws-auth configmap
    authentication_mode = "API"

    # Gives the creator admin access automatically
    bootstrap_cluster_creator_admin_permissions = true
  }

  ########################################
  # NETWORK CONFIG
  ########################################
  # This tells EKS which subnets to use

  vpc_config {

    # Use PRIVATE subnets for security (best practice)
    subnet_ids = aws_subnet.private[*].id

    # Allow internal communication inside VPC
    endpoint_private_access = true

    # Allow external access (needed for kubectl/Jenkins)
    endpoint_public_access = true
  }

  ########################################
  # DEPENDENCIES
  ########################################
  # Make sure IAM role is ready first

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  ########################################
  # TAGS
  ########################################

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 EKS Cluster"
  })
}

########################################
# EKS NODE GROUP (WORKER NODES)
########################################
# These are the EC2 instances that actually run your containers (pods)

resource "aws_eks_node_group" "main" {

  # Attach to the EKS cluster
  cluster_name = aws_eks_cluster.main.name

  # Name of the node group
  node_group_name = "tech-challenge-2-node-group"

  # IAM role for EC2 nodes
  node_role_arn = aws_iam_role.eks_node_role.arn

  # Place nodes in PRIVATE subnets
  subnet_ids = aws_subnet.private[*].id

  ########################################
  # INSTANCE SETTINGS
  ########################################

  # Use on-demand instances (not spot)
  capacity_type = "ON_DEMAND"

  # Instance type = t3.small (your requirement)
  instance_types = [var.node_instance_type]

  # Disk size for nodes
  disk_size = 20

  ########################################
  # AUTO SCALING CONFIG
  ########################################
  # This matches your requirement:
  # - min = 1 node
  # - desired = 1 node
  # - max = 4 nodes

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  ########################################
  # UPDATE SETTINGS
  ########################################
  # Controls how nodes update (rolling updates)

  update_config {
    max_unavailable = 1
  }

  ########################################
  # LABELS
  ########################################
  # Labels help organize nodes in Kubernetes

  labels = {
    workload = "general"
  }

  ########################################
  # DEPENDENCIES
  ########################################

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_ecr_pull_policy,
    aws_iam_role_policy_attachment.eks_cni_policy
  ]

  ########################################
  # TAGS
  ########################################

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 EKS Node Group"
  })
}

########################################
# JENKINS ACCESS TO EKS
########################################
# This allows your Jenkins EC2 instance to talk to the cluster

resource "aws_eks_access_entry" "jenkins" {

  # Cluster name
  cluster_name = aws_eks_cluster.main.name

  # IAM role attached to Jenkins EC2
  principal_arn = aws_iam_role.jenkins_role.arn

  # Standard access type
  type = "STANDARD"

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 Jenkins EKS Access Entry"
  })
}

########################################
# GIVE JENKINS ADMIN PERMISSIONS
########################################
# This lets Jenkins deploy apps using kubectl

resource "aws_eks_access_policy_association" "jenkins_cluster_admin" {

  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_iam_role.jenkins_role.arn

  # Full admin access inside Kubernetes
  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.jenkins
  ]
}
########################################

# ALLOW JENKINS TO TALK TO EKS API

########################################

# This opens port 443 from the Jenkins EC2 security group

# to the EKS cluster security group so kubectl can reach the cluster.

resource "aws_vpc_security_group_ingress_rule" "eks_api_from_jenkins" {

  # EKS cluster security group

  security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id

  # Jenkins EC2 security group

  referenced_security_group_id = aws_security_group.jenkins.id

  # HTTPS

  from_port = 443

  to_port = 443

  ip_protocol = "tcp"

  tags = merge(local.common_tags, {

    Name = "Tech Challenge 2 EKS API Access From Jenkins"

  })

}