resource "aws_eks_cluster" "eks-cluster" {
    name = "learn-eks-cluster"
    role_arn = aws_iam_role.eks_cluster_iam_role.role_arn
    version = var.eks_version
    vpc_config {
        subnet_ids = data.aws_subnets.routable-subnets.ids
        endpoint_private_access = true
        endpoint_public_access = true
    }

    depends_on = [aws_iam_role.eks_cluster_iam_role]
}
