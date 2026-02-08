output "developer_user_arn" {
  value = aws_iam_user.developer.arn
}

output "developer_user_name" {
  value = aws_iam_user.developer.name
}

output "manager_user_arn" {
  value = aws_iam_user.manager.arn
}

output "manager_user_name" {
  value = aws_iam_user.manager.name
}
