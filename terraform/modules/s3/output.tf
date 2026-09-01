output "s3_bucket_id" {
    value = aws_s3_bucket.frontend.id
}

output "bucket_regional_domain_name" {
   value = aws_s3_bucket.frontend.bucket_regional_domain_name
}


output "s3_bucket" {
  value = aws_s3_bucket.frontend.bucket
}

output "s3_arn" {
  value = aws_s3_bucket.frontend.arn
}