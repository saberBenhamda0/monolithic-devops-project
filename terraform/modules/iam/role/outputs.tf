output "eks_admin_role_arn" {
  value = aws_iam_role.eks_admin.arn
}

output "eks_admin_role_name" {
  value = aws_iam_role.eks_admin.name
}

output "cluster_autoscaler_role_arn" {
  value = aws_iam_role.cluster_autoscaler.arn
}

output "cluster_autoscaler_role_name" {
  value = aws_iam_role.cluster_autoscaler.name
}

output "aws_lbc_role_name" {
  value = aws_iam_role.aws_lbc.name
}
