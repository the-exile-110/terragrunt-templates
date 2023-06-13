resource "helm_release" "load_balancer_controller" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  namespace = "kube-system"

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller"
    # Changes based on Region - This is for us-east-1 Additional Reference: https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.load_balancer_controller.arn
  }

  set {
    name  = "vpcId"
    value = var.vpc_configs.vpc_id
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }
}

resource "helm_release" "metric_server" {
  name       = "metric-server"
  chart      = "metrics-server"
  repository = "https://charts.bitnami.com/bitnami"
  namespace  = "kube-system"
  set {
    name  = "apiService.create"
    value = "true"
  }
}

// kubectl get pods -n argocd
// kubectl port-forward svc/argocd-server -n argocd 8080:443
// kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
resource "helm_release" "argocd" {
  depends_on = [helm_release.load_balancer_controller]

  name             = "argocd"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "5.36.1"
  repository       = "https://argoproj.github.io/argo-helm"
  set {
    name  = "server.service.type"
    value = "NodePort"
  }
  set {
    name  = "server.extraArgs"
    value = "{--insecure,--request-timeout=\"5m\"}"
  }

}