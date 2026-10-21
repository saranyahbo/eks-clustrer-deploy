data "aws_caller_identity" "current" {}

data "aws_vpc" "eks_vpc" {
    filter {
      name= "tag:Name"
      values = ["eks-vpc"]
    }
}

data "aws_subnets" "routable-subnets" {
    filter {
      name= "tag:Name"
      values = ["routable*"]
    }
    filter {
      name   = "vpc-id"
      values = [data.aws_vpc.eks_vpc.id]
    }
    filter {
      name= availability-zone
      values = [var.preferred_azs[0]]
    }
}

data "aws_subnets" "non-routable-subnets" {
    filter {
      name= "tag:Name"
      values = ["non-routable*"]
    }
    filter {
      name   = "vpc-id"
      values = [data.aws_vpc.eks_vpc.id]
    }
}