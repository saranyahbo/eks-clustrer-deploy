resource "aws_eks" "eks-cluster" {
    name = "DemoEKSCluster"
    role_arn = aws_iam_role.eks_cluster_iam_role.role_arn
    version = var.eks_version

    
}
