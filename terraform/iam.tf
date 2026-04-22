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

data "aws_iam_policy_document" "jenkins_eks_access" {
  statement {
    sid    = "AllowDescribeEKS"
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "jenkins_eks_access" {
  name        = "tech-challenge-2-jenkins-eks-access-policy"
  description = "Lets Jenkins discover EKS clusters for kubectl setup"
  policy      = data.aws_iam_policy_document.jenkins_eks_access.json

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 Jenkins EKS Access Policy"
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_eks_access" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_eks_access.arn
}

resource "aws_iam_role_policy_attachment" "jenkins_ecr_poweruser" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "tech-challenge-2-jenkins-instance-profile"
  role = aws_iam_role.jenkins_role.name

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 Jenkins Instance Profile"
  })
}