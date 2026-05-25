## IAM Cluster role for EKS
resource "aws_iam_role" "eks_cluster_iam_role" {
    name = "eks_cluster_iam_role"
    assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
    statement {
      effect = "Allow"
      principals {
        type = "Service"
        identifiers = ["eks.amazonaws.com"]
      }
      actions = ["sts:AssumeRole"]
    }
}

## AWS managed policies association
resource "aws_iam_role_policy_attachment" "EKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.eks_cluster_iam_role.name
}

##IAM role for EKS worker node
resource "aws_iam_role" "EKSWorkerNoderole" {
    name = "eks_worker_node_role"
    assume_role_policy = data.aws_iam_policy_document.eks_worker_role_policy.json
}

data "aws_iam_policy_document" "eks_worker_role_policy" {
    statement {
      effect = "Allow"
      principals {
        type = "Service"
        identifiers = ["ec2.amazonaws.com"]
      }
      actions = ["sts:AssumeRole"]
    }
}

##Policy attachment for worker node role

## for kubernetes worker functionality
resource "aws_iam_role_policy_attachment" "EKSWorkerNodePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role = aws_iam_role.eks_worker_node_role.name
}
## For Pod networking/ENI allocation
resource "aws_iam_role_policy_attachment" "EKSCNIPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role = aws_iam_role.eks_worker_node_role.name
}
## to pull Docker images from ECR
resource "aws_iam_role_policy_attachment" "EC2ContainerRegistryPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.eks_worker_node_role.name
}