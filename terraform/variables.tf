variable "argocd_username" {
  type        = string
  description = "ArgoCD admin username"
}

variable "argocd_password" {
  type        = string
  description = "ArgoCD admin password"
  sensitive   = true
}

variable "deployer_public_key" {
  type        = string
  description = "deployer_public_key"
  sensitive   = true
}

variable "db_username" {
  type        = string
  description = "db_username"
}

variable "db_password" {
  type        = string
  description = "db_password"
  sensitive   = true
}

variable "db_name" {
  type = string
}