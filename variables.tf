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