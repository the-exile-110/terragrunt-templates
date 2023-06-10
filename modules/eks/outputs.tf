output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "load_balancer_controller_policy_arn" {
  value = aws_iam_policy.load_balancer_controller.arn
}

output "load_balancer_controller_role_arn" {
  description = "AWS Load Balancer Controller IAM Role ARN"
  value       = aws_iam_role.load_balancer_controller.arn
}

output "helm_load_balancer_controller_metadata" {
  description = "Metadata Block outlining status of the deployed release."
  value       = helm_release.load_balancer_controller.metadata
}