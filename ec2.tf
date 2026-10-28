data "aws_ami" "amazon-linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "bastion-host" {
    ami = data.aws_ami.amazon-linux.id
    instance_type = "t3.micro"
    subnet_id = data.aws_subnets.routable-subnets.ids[0]
    vpc_security_group_ids = [aws_security_group.bastion-sg.id]
    iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
    key_name = "eks-ssh-key"
    user_data = templatefile("./templates/eks_user_data_script.sh", {
        region              = "us-east-1"
        cluster_name        = aws_eks_cluster.eks-cluster.name
        node_group_name     = aws_eks_node_group.worker_node_group.node_group_name
        node_group_role_arn = aws_iam_role.EKSWorkerNoderole.arn
        k8s_version         = var.k8s_version
        eksctl_architecture = var.eksctl_architecture
        argocd_version      = var.argocd_version
    })
    tags = {
      Name = "bastion-host"
    }
}

resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Register public key in AWS
resource "aws_key_pair" "ec2_key" {
  key_name   = "eks-ssh-key"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.ec2_key.private_key_pem
  filename        = "${path.module}/dev-ec2-key.pem"
  file_permission = "0400"
}

resource "aws_security_group" "bastion-sg" {
  name        = "bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = data.aws_vpc.eks_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"  
    cidr_blocks = ["0.0.0.0/16"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"  
    cidr_blocks = ["0.0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}