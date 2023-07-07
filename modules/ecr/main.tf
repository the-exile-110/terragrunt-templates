module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  for_each = {for idx, repo in var.ecr : idx => repo}

  repository_name                   = each.value.repository_name
  repository_read_write_access_arns = each.value.repository_read_write_access_arns != null ? each.value.repository_read_write_access_arns : []
  repository_lifecycle_policy       = each.value.repository_lifecycle_policy
}