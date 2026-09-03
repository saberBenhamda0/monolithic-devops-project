variable "eks_admin_role_arn" {
  type        = string
  description = "ARN of the EKS Admin Role for AssumeRole policy"
}

variable "aws_cloudfront_distribution_frontend_id" {
  type = string
}

variable "s3_arn" {
  type = string
}