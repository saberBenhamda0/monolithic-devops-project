variable "vpc_id" {
  type = string
}

variable "k8_public_subnets_cidr_blocks" {
  type        = list(string)
  description = "list of the public cidr blocks for worker nodes in k8"
}
variable "vpn_cicd" {
  type        = list(string)
  description = "vpn_cicd"
}

variable "vault_cidr" {
  type        = list(string)
  description = "vpn_cicd"
}