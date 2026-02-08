variable "eks_admin_role_name" { type = string }
variable "eks_admin_policy_arn" { type = string }

variable "cluster_autoscaler_role_name" { type = string }
variable "cluster_autoscaler_policy_arn" { type = string }

variable "developer_user_name" { type = string }
variable "manager_user_name" { type = string }

variable "eks_developers_policy_arn" { type = string }
variable "eks_manager_policy_arn" { type = string }

variable "aws_lbc_policy_arn" { type = string }
variable "aws_lbc_role_name" { type = string }
