// argocd
// kubectl get pods -n argocd
// kubectl port-forward svc/argo-cd-argocd-server -n argocd 8080:443
// kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

// prometheus
// kubectl get pods -n kube-prometheus-stack
// kubectl port-forward svc/prometheus-server -n kube-prometheus-stack 9090:9090
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name                    = "${var.prefix_env}-eks"
  cluster_version                 = var.eks_configs.cluster_version
  cluster_endpoint_private_access = var.eks_configs.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.eks_configs.cluster_endpoint_public_access
  create_kms_key                  = var.eks_configs.create_kms_key

  vpc_id                   = var.vpc_configs.vpc_id
  subnet_ids               = var.vpc_configs.subnet_ids
  control_plane_subnet_ids = var.vpc_configs.control_plane_subnet_ids

  eks_managed_node_group_defaults = var.eks_configs.eks_managed_node_group_defaults
  eks_managed_node_groups         = {
    default = var.eks_configs.eks_managed_node_groups.default
  }
  node_security_group_additional_rules = {
    aws_lb_controller_webhook = {
      description                   = "Cluster API to AWS LB Controller webhook"
      protocol                      = "all"
      from_port                     = 9443
      to_port                       = 9443
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }
}

module "eks_blueprints_addons" {
  depends_on = [module.eks]

  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.0.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  enable_aws_cloudwatch_metrics       = true
  enable_aws_for_fluentbit            = true
  enable_aws_load_balancer_controller = true
  enable_karpenter                    = true
  enable_kube_prometheus_stack        = true
  enable_metrics_server               = true
  enable_argocd                       = true
  enable_argo_rollouts                = true
  enable_argo_workflows               = true
  enable_external_dns                 = true
  enable_cert_manager                 = true
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
  depends_on = [module.eks_auth]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region} --profile ${var.aws_profile}"
  }
}
