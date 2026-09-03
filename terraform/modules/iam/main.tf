module "role" {
  source = "./role"
}

module "policy" {
  source                                  = "./policy"
  eks_admin_role_arn                      = module.role.eks_admin_role_arn
  aws_cloudfront_distribution_frontend_id = var.aws_cloudfront_distribution_frontend_id
  s3_arn                                  = var.s3_arn
}

module "user" {
  source = "./user"
}

module "attachment" {
  source = "./attachment"

  eks_admin_role_name  = module.role.eks_admin_role_name
  eks_admin_policy_arn = module.policy.eks_admin_policy_arn

  cluster_autoscaler_role_name  = module.role.cluster_autoscaler_role_name
  cluster_autoscaler_policy_arn = module.policy.cluster_autoscaler_policy_arn

  developer_user_name       = module.user.developer_user_name
  eks_developers_policy_arn = module.policy.eks_developers_policy_arn

  manager_user_name      = module.user.manager_user_name
  eks_manager_policy_arn = module.policy.eks_manager_policy_arn

  aws_lbc_role_name  = module.role.aws_lbc_role_name
  aws_lbc_policy_arn = module.policy.aws_lbc_policy_arn

  jenkins_frontend_deploy_policy_arn = module.policy.jenkins_frontend_deploy_policy_arn
  pipelines_admin_name               = module.user.pipelines_admin_name


  jenkins_deploy_role_arn  = module.role.jenkins_deploy_role_arn
  jenkins_deploy_role_name = module.role.jenkins_deploy_role_name
}

# Access Entries
resource "aws_eks_access_entry" "manager" {

  cluster_name  = var.eks_name
  principal_arn = module.role.eks_admin_role_arn

  # the kubernetes RBAC group this eks_acces_entry map to
  kubernetes_groups = ["my-admin"]

  depends_on = [var.eks]
}

resource "aws_eks_access_entry" "developer" {
  cluster_name  = var.eks_name
  principal_arn = module.user.developer_user_arn

  # the kubernetes RBAC group this eks_acces_entry map to
  kubernetes_groups = ["developers"]

  depends_on = [var.eks]
}