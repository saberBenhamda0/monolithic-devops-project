variable "cidr_block" {
  type = string

  description = "cidr that represnt number of the subnet and host we could have in the vpc"
}


variable "public_subnets" {
  type = list(string)
  description = "cidr  for the public_subnets"
}

variable "private_subnets" {
  type = list(string)
  description = "cidr for the private_subnets"
}

variable "zones" {
    type = list(string)
    description = "zones where subnet gonna live"
}