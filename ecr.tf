resource "aws_ecr_repository" "ecr_repo" {
  name                 = "learn-eks"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
