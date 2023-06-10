terraform {
  source = "${find_in_parent_folders("modules/xxx")}///"
}

prevent_destroy = false

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  env_vars = include.root.locals.env_vars
}

#dependency "vpc" {
#  config_path = "../vpc"

#  mock_outputs = {
#    vpc_id = "vpc-12345678"
#  }
#}

inputs = {
  aws_account_id = local.env_vars.aws_account_id
  aws_region     = local.env_vars.aws_region
  env            = local.env_vars.env
  prefix_env     = local.env_vars.prefix_env

  // vpc_id = dependency.vpc.outputs.vpc_id
}