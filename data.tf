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
}

data "aws_subnets" "non-routable-subnets" {
    filter {
      name= "tag:Name"
      values = ["non-routable*"]
    }
}
