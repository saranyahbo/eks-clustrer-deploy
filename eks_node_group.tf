resource "aws_eks_node_group" "worker_node_group" {
    node_group_name = "eks-node-group"
    cluster_name = aws_eks_cluster.eks-cluster.name
    node_role_arn = aws_iam_role.EKSWorkerNoderole.arn
    subnet_ids = data.aws_subnets.routable-subnets.ids 
    instance_types = ["c7i-flex.large"]

    scaling_config {
        desired_size = 2
        max_size = 3
        min_size = 2
    }
    depends_on = [
        aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly-EKS,
        aws_iam_role_policy_attachment.EKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.EKSCNIPolicy
    ]
}
