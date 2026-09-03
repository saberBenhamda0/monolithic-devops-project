variable "eks_name" {
    type = string
    description = "the name of the eks cluster"
}

variable "eks" {
  description = "the full eks resource"
}

variable "s3_arn" {
    description = "s3_arn"
}

variable "aws_cloudfront_distribution_frontend_id" {
  description = "aws_cloudfront_distribution_frontend_id"
}
