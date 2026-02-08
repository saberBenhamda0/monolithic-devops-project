output "eks_admin_policy_arn" {
  value = aws_iam_policy.eks_admin.arn
}

output "eks_manager_policy_arn" {
  value = aws_iam_policy.eks_manager.arn
}

output "eks_developers_policy_arn" {
  value = aws_iam_policy.eks_developers.arn
}

output "cluster_autoscaler_policy_arn" {
  value = aws_iam_policy.cluster_autoscaler.arn
}

output "aws_lbc_policy_arn" {
  value = aws_iam_policy.aws_lbc.arn
}
