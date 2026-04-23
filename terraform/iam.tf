########################################
# AWS ACCOUNT INFO
########################################

data "aws_caller_identity" "current" {}

########################################
# EKS CLUSTER IAM ROLE
########################################

data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    sid     = "EKSClusterAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name               = "tech-challenge-2-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 EKS Cluster Role"
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

########################################
# EKS NODE IAM ROLE
########################################

data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    sid     = "EKSNodeAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node_role" {
  name               = "tech-challenge-2-eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 EKS Node Role"
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr_pull_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

########################################
# JENKINS IAM ROLE
########################################

data "aws_iam_policy_document" "jenkins_assume_role" {
  statement {
    sid     = "JenkinsAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "jenkins_role" {
  name               = "tech-challenge-2-jenkins-role"
  assume_role_policy = data.aws_iam_policy_document.jenkins_assume_role.json

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 Jenkins Role"
  })
}

########################################
# JENKINS EKS ACCESS
########################################

data "aws_iam_policy_document" "jenkins_eks_access" {
  statement {
    sid    = "AllowEKSAccess"
    effect = "Allow"

    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters",
      "eks:DescribeClusterVersions",
      "eks:TagResource"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "jenkins_eks_access" {
  name        = "tech-challenge-2-jenkins-eks-access-policy"
  description = "Allows Jenkins to discover and connect to EKS"
  policy      = data.aws_iam_policy_document.jenkins_eks_access.json

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 Jenkins EKS Access Policy"
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_eks_access" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_eks_access.arn
}

########################################
# JENKINS ECR ACCESS
########################################

resource "aws_iam_role_policy_attachment" "jenkins_ecr_poweruser" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

########################################
# JENKINS FULL EKS PERMISSIONS
########################################

resource "aws_iam_role_policy_attachment" "jenkins_eks_cluster_policy" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "jenkins_eks_service_policy" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

########################################
# AWS LOAD BALANCER CONTROLLER POLICY
########################################

resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Permissions for AWS Load Balancer Controller to create ALBs"

  policy = file("${path.module}/aws-load-balancer-controller-policy.json")

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 ALB Controller IAM Policy"
  })
}

########################################
# AWS LOAD BALANCER CONTROLLER ROLE
########################################

locals {
  oidc_provider_url = replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")
}

data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_provider_url}"
      ]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  name               = "tech-challenge-2-alb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role.json

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 ALB Controller Role"
  })
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}

########################################
# INSTANCE PROFILE FOR EC2
########################################

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "tech-challenge-2-jenkins-instance-profile"
  role = aws_iam_role.jenkins_role.name

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 Jenkins Instance Profile"
  })
}