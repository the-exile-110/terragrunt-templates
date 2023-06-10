terraform {
  source = "${find_in_parent_folders("modules/vpc")}///"
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
  vpc_configs    = local.env_vars.vpc
}
