variable "cidr_block" {
  type = string

  description = "cidr that represnt number of the subnet and host we could have in the vpc"
}

variable "public_subnets" {
  type = list(object({
    cidr_block = string
    zone       = string
    tags       = string
  }))
}

variable "private_subnets" {
  type = list(object({
    cidr_block = string
    zone       = string
    tags       = string
  }))
}