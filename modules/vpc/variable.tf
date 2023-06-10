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

variable "vpc_configs" {
  type = object({
    cidr_block                           = string
    azs                                  = list(string)
    private_subnets                      = list(string)
    public_subnets                       = list(string)
    enable_nat_gateway                   = bool
    single_nat_gateway                   = bool
    enable_dns_hostnames                 = bool
    enable_flow_log                      = bool
    create_flow_log_cloudwatch_iam_role  = bool
    create_flow_log_cloudwatch_log_group = bool
    public_subnet_tags                   = map(string)
    private_subnet_tags                  = map(string)
  })
}