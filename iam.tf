#ec2 instance role for SSM
resource "aws_iam_policy" "ssm_policy" {
    name = "ssm-policy"
    description = "IAM policy for SSM"
    policy = jsonencode({
        "Version" = "2012-10-17"
        "Statement" = [
            {
                "Effect" = "Allow"
                "Action" = [
                    "ssm:DescribeInstanceInformation",
                    "ssm:GetCommandInvocation",
                    "ssm:ListCommands",
                    "ssm:ListCommandInvocations",
                    "ssm:SendCommand",
                    "ssm:Describe*",
                    "ssm:Get*",
                    "ssm:List*"
                ]
                "Resource" = "*"
            },
            {
                "Effect" = "Allow"
                "Action" = [
                    "ec2messages:AcknowledgeMessage",
                    "ec2messages:DeleteMessage",
                    "ec2messages:FailMessage",
                    "ec2messages:GetEndpoint",
                    "ec2messages:GetMessages",
                    "ec2messages:SendReply"
                ]
                "Resource" = "*"
            },
            {
                "Effect" = "Allow"
                "Action" = [
                    "ssmmessages:*"
                ]
                "Resource" = "*"
            }
        ]

    })
}

resource "aws_iam_role" "ssm_role" {
    name = "ssm_ec2-role"
    assume_role_policy = jsonencode({
        "Version" = "2012-10-17"
        "Statement" = [
            {
                "Effect" = "Allow"
                "Principal" = {
                    "Service" = "ec2.amazonaws.com"
                }
                "Action" = "sts:AssumeRole"
            }
        ]
    })

}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
    role = aws_iam_role.ssm_role.name
    policy_arn = aws_iam_policy.ssm_policy.arn
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
    name = "ssm_instance_profile"
    role = aws_iam_role.ssm_role.name
}

resource "aws_iam_role_policy_attachment" "SSMPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    role = aws_iam_role.ssm_role.name
}

resource "aws_iam_role_policy_attachment" "SSMPolicy1" {
    policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
    role = aws_iam_role.ssm_role.name
}

resource "aws_iam_role_policy_attachment" "SSMPolicy2" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.ssm_role.name
}

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

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.eks_cluster_iam_role.name
}

resource "aws_iam_role_policy_attachment" "LoadbalancerControllerPolicy" {
    policy_arn = "arn:aws:iam::598206844002:policy/AWSLoadBalancerControllerIAMPolicy"
    role = aws_iam_role.alb_controller.name
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
    role = aws_iam_role.EKSWorkerNoderole.name
}
## For Pod networking/ENI allocation
resource "aws_iam_role_policy_attachment" "EKSCNIPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role = aws_iam_role.EKSWorkerNoderole.name
}
## to pull Docker images from ECR
resource "aws_iam_role_policy_attachment" "EC2ContainerRegistryPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.EKSWorkerNoderole.name
}

resource "aws_eks_access_entry" "bastion_access" {
  cluster_name  = aws_eks_cluster.eks-cluster.name
  principal_arn = aws_iam_role.ssm_role.arn
  type          = "STANDARD"

  tags = {
    Name        = "eks-bastion-access"
    Environment = "dev"
  }
}

resource "aws_eks_access_policy_association" "bastion_admin" {
  cluster_name  = aws_eks_cluster.eks-cluster.name
  principal_arn = aws_eks_access_entry.bastion_access.principal_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = aws_eks_cluster.eks-cluster.name
  principal_arn = data.aws_caller_identity.current.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_actions_kube_system_admin" {
  cluster_name  = aws_eks_cluster.eks-cluster.name
  principal_arn = aws_eks_access_entry.github_actions.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"

  access_scope {
    type       = "namespace"
    namespaces = ["kube-system"]
  }
}