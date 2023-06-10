module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0"

  name = "${var.prefix_env}-vpc"
  cidr = var.vpc_configs.cidr_block

  azs                     = var.vpc_configs.azs
  private_subnets         = var.vpc_configs.private_subnets
  public_subnets          = var.vpc_configs.public_subnets
  map_public_ip_on_launch = var.vpc_configs.map_public_ip_on_launch

  enable_nat_gateway   = var.vpc_configs.enable_nat_gateway
  single_nat_gateway   = var.vpc_configs.single_nat_gateway
  enable_dns_hostnames = var.vpc_configs.enable_dns_hostnames

  enable_flow_log                      = var.vpc_configs.enable_flow_log
  create_flow_log_cloudwatch_iam_role  = var.vpc_configs.create_flow_log_cloudwatch_iam_role
  create_flow_log_cloudwatch_log_group = var.vpc_configs.create_flow_log_cloudwatch_log_group

  public_subnet_tags  = var.vpc_configs.public_subnet_tags == null ? {} : var.vpc_configs.public_subnet_tags
  private_subnet_tags = var.vpc_configs.private_subnet_tags == null ? {} : var.vpc_configs.private_subnet_tags

  tags = {
    Name = "${var.prefix_env}-vpc"
  }
}