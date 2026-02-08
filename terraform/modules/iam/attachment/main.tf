resource "aws_iam_role_policy_attachment" "eks_admin" {
  role       = var.eks_admin_role_name
  policy_arn = var.eks_admin_policy_arn
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  role       = var.cluster_autoscaler_role_name
  policy_arn = var.cluster_autoscaler_policy_arn
}

resource "aws_iam_user_policy_attachment" "developer" {
  user       = var.developer_user_name
  policy_arn = var.eks_developers_policy_arn
}

resource "aws_iam_user_policy_attachment" "manager" {
  user       = var.manager_user_name
  policy_arn = var.eks_manager_policy_arn
}

resource "aws_iam_role_policy_attachment" "aws_lbc" {
  policy_arn = var.aws_lbc_policy_arn
  role       = var.aws_lbc_role_name
}