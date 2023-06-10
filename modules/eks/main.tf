module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name                    = "${var.prefix_env}-eks"
  cluster_version                 = var.eks_configs.cluster_version
  cluster_endpoint_private_access = var.eks_configs.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.eks_configs.cluster_endpoint_public_access

  vpc_id                   = var.vpc_configs.vpc_id
  subnet_ids               = var.vpc_configs.subnet_ids
  control_plane_subnet_ids = var.vpc_configs.control_plane_subnet_ids

  eks_managed_node_group_defaults = var.eks_configs.eks_managed_node_group_defaults
  eks_managed_node_groups         = {
    default = var.eks_configs.eks_managed_node_groups.default
  }
}

resource "aws_eks_addon" "kube_proxy" {
  depends_on = [module.eks]

  cluster_name                = module.eks.cluster_name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "vpc_cni" {
  depends_on = [module.eks]

  cluster_name                = module.eks.cluster_name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "coredns" {
  depends_on = [module.eks]

  cluster_name                = module.eks.cluster_name
  addon_name                  = "coredns"
  resolve_conflicts_on_update = "PRESERVE"
}

module "eks_auth" {
  depends_on = [module.eks]

  source  = "aidanmelen/eks-auth/aws"
  version = "1.0.0"
  eks     = module.eks

  map_roles    = var.eks_configs.aws_auth_roles == null ? [] : var.eks_configs.aws_auth_roles
  map_users    = var.eks_configs.aws_auth_users
  map_accounts = concat([var.aws_account_id], var.eks_configs.aws_auth_accounts)
}

resource "null_resource" "update_k8s_config" {
  depends_on = [module.eks, module.eks_auth]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region} --profile ${var.aws_profile}"
  }
}
