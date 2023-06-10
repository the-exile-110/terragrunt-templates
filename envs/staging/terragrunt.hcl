locals {
  env_vars = merge(
    yamldecode(file("../configs/common.yaml")),
    yamldecode(file("../configs/staging.yaml"))
  )

  default_tags = merge(local.env_vars.terraform.default_tags, {
    Environment = local.env_vars.aws.env
  })
}

terraform {
  extra_arguments "aws_profile" {
    commands = ["init", "apply", "refresh", "import", "plan", "taint", "untaint"]
    env_vars = {
      AWS_PROFILE = local.env_vars.aws.profile
    }
  }
}

remote_state {
  backend = "s3"
  config  = {
    profile = local.env_vars.remote_state_config.profile
    bucket  = local.env_vars.remote_state_config.bucket
    key     = "${local.env_vars.aws.account_id}/${local.env_vars.aws.env}/${path_relative_to_include()}.tfstate"
    region  = local.env_vars.aws.region
    encrypt = true
  }
}

generate "provider" {
  path      = "_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    provider "aws" {
      profile = "${local.env_vars.aws.profile}"
      region = "${local.env_vars.aws.region}"
      default_tags {
        tags = ${jsonencode(local.default_tags)}
      }
    }
  EOF
}

generate "version" {
  path      = "_version.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_version = "${local.env_vars.terraform.required_version}"
      backend "s3" {}

      required_providers {
        aws = ${jsonencode(local.env_vars.terraform.providers.aws)}
      }
    }
  EOF
}
