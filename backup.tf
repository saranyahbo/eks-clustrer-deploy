terraform {
    backend "s3" {
        bucket = "learn-eks-cluster-tfstate"
        key    = "eks-cluster/terraform.tfstate"
        region = "us-east-1"
    }
}