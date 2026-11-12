terraform {
    backend "s3" {
        bucket = "learn-eks-cluster-tfstate-bucket"
        key    = "eks-cluster/terraform.tfstate"
        region = "us-east-1"
    }
}