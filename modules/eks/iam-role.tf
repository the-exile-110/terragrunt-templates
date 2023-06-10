resource "aws_iam_policy" "load_balancer_controller" {
  name        = "${var.prefix_env}-load-balancer-controller-policy"
  path        = "/"
  description = "AWS Load Balancer Controller IAM Policy"
  policy      = file("./policy-json/load-balancer-controller.json")
}

resource "aws_iam_role" "load_balancer_controller" {
  name = "${var.prefix_env}-load-balancer-controller-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRoleWithWebIdentity"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider_arn}:aud" : "sts.amazonaws.com",
            "${module.eks.oidc_provider_arn}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      },
    ]
  })

  tags = {
    tag-key = "AWSLoadBalancerControllerIAMPolicy"
  }
}

resource "aws_iam_role_policy_attachment" "lbc_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.load_balancer_controller.arn
  role       = aws_iam_role.load_balancer_controller.name
}