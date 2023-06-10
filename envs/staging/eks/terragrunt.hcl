terraform {
  source = "${find_in_parent_folders("modules/eks")}///"
}

prevent_destroy = false

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  env_vars = include.root.locals.env_vars
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id         = "vpc-12345678"
    public_subnets = ["subnet-12345678", "subnet-12345678", "subnet-12345678"]
  }
}

inputs = {
  aws_account_id = local.env_vars.aws.account_id
  aws_region     = local.env_vars.aws.region
  aws_profile    = local.env_vars.aws.profile
  env            = local.env_vars.aws.env
  prefix_env     = local.env_vars.aws.prefix_env

  # VPC
  vpc_configs = {
    vpc_id                   = dependency.vpc.outputs.vpc_id
    subnet_ids               = slice(dependency.vpc.outputs.public_subnets, 0, 3)
    control_plane_subnet_ids = slice(dependency.vpc.outputs.public_subnets, 3, 6)
    vpc_security_group_ids   = []
  }

  # EKS
  eks_configs = local.env_vars.eks.eks_on_ec2
}