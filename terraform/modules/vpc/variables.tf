variable "cidr_block" {
  type        = string
  description = "cidr that represnt number of the subnet and host we could have in the vpc"
}

variable "public_subnets" {
  type = map(object({
    cidr_block = string
    zone       = string
  }))
  description = "Map of public subnets, keyed by a unique subnet name"
}

variable "private_subnets" {
  type = map(object({
    cidr_block = string
    zone       = string
  }))
  description = "Map of private subnets, keyed by a unique subnet name"
}