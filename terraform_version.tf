terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">=5.0.0"
        }
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = ">=2.0.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}

data "aws_eks_cluster" "alb_controller" {
    name = aws_eks_cluster.eks-cluster.name
}

provider "kubernetes" {
    host                   = data.aws_eks_cluster.alb_controller.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.alb_controller.certificate_authority[0].data)

    exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        command     = "aws"
        args = [
            "eks",
            "get-token",
            "--cluster-name",
            data.aws_eks_cluster.alb_controller.name,
            "--region",
            "us-east-1"
        ]
    }
}