module "exam_repo" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "1.6.0"

  repository_name                   = var.exam_repo.repository_name
  repository_read_write_access_arns = var.exam_repo.repository_read_write_access_arns
  repository_lifecycle_policy       = var.exam_repo.repository_lifecycle_policy
}