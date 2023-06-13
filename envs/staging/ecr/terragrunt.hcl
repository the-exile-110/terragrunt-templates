terraform {
  source = "${find_in_parent_folders("modules/ecr")}///"
}


prevent_destroy = false

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  env_vars = include.root.locals.env_vars
}

inputs = {
  aws_account_id = local.env_vars.aws.account_id
  aws_region     = local.env_vars.aws.region
  env            = local.env_vars.aws.env
  prefix_env     = local.env_vars.aws.prefix_env

  # test repo
  force_delete         = local.env_vars.ecr.test_repo.force_delete
  image_tag_mutability = local.env_vars.ecr.test_repo.image_tag_mutability
  scan_on_push         = local.env_vars.ecr.test_repo.scan_on_push
  encryption_type      = local.env_vars.ecr.test_repo.encryption_type
  kms_key              = local.env_vars.ecr.test_repo.kms_key
}
