module "role" {
  source = "./role"
}

module "policy" {
  source = "./policy"
  eks_admin_role_arn = module.role.eks_admin_role_arn
}

module "user" {
  source = "./user"
}

module "attachment" {
  source = "./attachment"

  eks_admin_role_name           = module.role.eks_admin_role_name
  eks_admin_policy_arn          = module.policy.eks_admin_policy_arn
  
  cluster_autoscaler_role_name  = module.role.cluster_autoscaler_role_name
  cluster_autoscaler_policy_arn = module.policy.cluster_autoscaler_policy_arn
  
  developer_user_name           = module.user.developer_user_name
  eks_developers_policy_arn     = module.policy.eks_developers_policy_arn
  
  manager_user_name             = module.user.manager_user_name
  eks_manager_policy_arn        = module.policy.eks_manager_policy_arn

  aws_lbc_role_name             = module.role.aws_lbc_role_name
  aws_lbc_policy_arn        = module.policy.aws_lbc_policy_arn
}

# Access Entries
resource "aws_eks_access_entry" "manager" {
  cluster_name      = var.eks_name
  principal_arn     = module.role.eks_admin_role_arn
  kubernetes_groups = ["my-admin"]

    depends_on = [ var.eks ]
}

resource "aws_eks_access_entry" "developer" {
  cluster_name      = var.eks_name
  principal_arn     = module.user.developer_user_arn
  kubernetes_groups = ["developers"]

  depends_on = [ var.eks ]
}