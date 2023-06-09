variable "env" {
  type = string
}

variable "prefix_env" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "vpc_configs" {
  type = object({
    vpc_id                   = string
    subnet_ids               = list(string)
    control_plane_subnet_ids = list(string)
    vpc_security_group_ids   = list(string)
  })
}

variable "eks_configs" {
  type = object({
    cluster_version                        = string
    cluster_endpoint_private_access        = bool
    cluster_endpoint_public_access         = bool
    cluster_iam_role_dns_suffix            = string
    create_kms_key                         = bool
    cloudwatch_log_group_retention_in_days = number
    eks_managed_node_group_defaults        = object({
      instance_type                          = string
      update_launch_template_default_version = bool
      iam_role_additional_policies           = map(string)
    })
    eks_managed_node_groups = object({
      default = object({
        name                       = string
        min_size                   = number
        max_size                   = number
        desired_size               = number
        pre_bootstrap_user_data    = string
        use_mixed_instances_policy = bool
        mixed_instances_policy     = object({
          instances_distribution                   = number
          on_demand_percentage_above_base_capacity = number
          spot_allocation_strategy                 = string
        })
        override = list(object({
          instance_type     = string
          weighted_capacity = number
        }))
      })
    })
    aws_auth_accounts = list(string)
    aws_auth_roles    = list(object({
      rolearn  = string
      username = string
      groups   = list(string)
    }))
    aws_auth_users = list(object({
      userarn  = string
      username = string
      groups   = list(string)
    }))
  })
}