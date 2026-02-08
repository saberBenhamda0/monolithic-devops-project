output "cluster_autoscaler_arn" {
  value = module.role.cluster_autoscaler_role_arn
}

output "eks_admin_role_arn" {
  value = module.role.eks_admin_role_arn
}