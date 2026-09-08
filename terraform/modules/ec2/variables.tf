variable "vpc_id" {
  description = "vpc id"
  type        = string
}

variable "aws_internet_gateway_id" {
  description = "internet gateway id"
  type        = string
}

variable "instances" {
  type = map(object({
    ami                 = string
    instance_type       = string
    subnet_id           = string
    private_ip          = string
    ssh_key_name        = string
    security_group_keys = optional(list(string), [])
    tags                = optional(map(string), {})
    user_data_script     = optional(string, "")
  }))
  description = "an object with proprieties of the instance"
}