variable "eks_version" {
    type = string
    description = "Version of the EKS cluster"
    default = "1.36"
}

variable "preferred_azs" {
    type = list(string)
    description = "List of preferred availability zones"
    default = ["us-east-1a", "us-east-1b"]
}

variable "k8s_version" {
    type        = string
    description = "Kubernetes minor version used to download kubectl"
    default     = "1.34"
}

variable "eksctl_architecture" {
    type        = string
    description = "CPU architecture used to download eksctl"
    default     = "amd64"
}

variable "argocd_version" {
    type        = string
    description = "Argo CD CLI version to install; empty uses the latest stable version"
    default     = ""
}