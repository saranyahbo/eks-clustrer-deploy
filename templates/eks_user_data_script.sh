#!/bin/bash
set -euxo pipefail

exec > >(tee /var/log/eks-user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# ==========================================
# 1. Update system packages
# ==========================================

dnf update -y

dnf install -y \
    git \
    curl \
    wget \
    unzip \
    tar \
    jq \
    bash-completion \
    yum-utils \
    docker

# ==========================================
# 2. Install AWS CLI v2
# ==========================================

cd /tmp

curl -fsSL \
"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
-o awscliv2.zip

unzip -q awscliv2.zip

./aws/install --update

aws --version

# ==========================================
# 3. Install kubectl
# ==========================================

# Set this to your EKS cluster's Kubernetes minor version.
K8S_VERSION="1.34"

curl -fsSL \
"https://s3.us-west-2.amazonaws.com/amazon-eks/${K8S_VERSION}/releases/latest/bin/linux/amd64/kubectl" \
-o /usr/local/bin/kubectl

chmod +x /usr/local/bin/kubectl

kubectl version --client

# ==========================================
# 4. Install eksctl
# ==========================================

ARCH=amd64
PLATFORM=Linux_${ARCH}

curl -fsSL \
"https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${PLATFORM}.tar.gz" \
-o eksctl.tar.gz

tar -xzf eksctl.tar.gz -C /tmp

mv /tmp/eksctl /usr/local/bin/eksctl

chmod +x /usr/local/bin/eksctl

eksctl version

# ==========================================
# 5. Install Helm
# ==========================================

curl -fsSL \
https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
-o /tmp/get_helm.sh

chmod 700 /tmp/get_helm.sh

/tmp/get_helm.sh

helm version

# ==========================================
# 6. Install Terraform
# ==========================================

dnf config-manager --add-repo \
https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

dnf install -y terraform

terraform version

# ==========================================
# 7. Configure Docker
# ==========================================

systemctl enable --now docker

usermod -aG docker ec2-user

docker --version

# ==========================================
# 8. Install Argo CD CLI
# ==========================================

ARGOCD_VERSION=$(curl -fsSL \
https://raw.githubusercontent.com/argoproj/argo-cd/stable/VERSION)

curl -fsSL \
"https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-amd64" \
-o /usr/local/bin/argocd

chmod +x /usr/local/bin/argocd

argocd version --client

# ==========================================
# 9. Configure kubectl completion
# ==========================================

kubectl completion bash \
> /etc/bash_completion.d/kubectl

# ==========================================
# 10. Cleanup
# ==========================================

rm -rf /tmp/aws
rm -f /tmp/awscliv2.zip
rm -f /tmp/eksctl.tar.gz
rm -f /tmp/get_helm.sh

echo "===================================="
echo "EKS Management Server Setup Complete"
echo "===================================="