variable "eks_name" {
  type = string
  description = "the name of the eks cluster"
}

variable "eks_version" {
    type = string
    description = "the version of the eks cluster"
}

variable "private_subnets" {
  type = list(string)
  description = "array of id's of the private subnets"
}

variable "public_subnets" {
    type = list(string)
  description = "array of id's of the public subnets"
}

variable "cluster_autoscaler_arn" {
  type = string
  description = "the cluster auto scaler iam role"
}