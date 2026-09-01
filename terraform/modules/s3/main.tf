resource "aws_s3_bucket" "frontend" {
  bucket = "manga2you_frontend" # must be globally unique across all of AWS

  tags = {
    Name = "Frontend Bucket"
  }
}

# Blocks all forms of public access - CloudFront will access it privately via OAC
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# all objects in the bucket belong to the owner of the bucket unlike the default behavios 
# where the uploader is the owner of the object
resource "aws_s3_bucket_ownership_controls" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Optional but nice to have: versioning so you can roll back bad deploys
resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  versioning_configuration {
    status = "Enabled"
  }
}

# this limit the old version to only save the previus 15 so we limit our aws bill 
resource "aws_s3_bucket_lifecycle_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    id     = "limit-noncurrent-versions"
    status = "Enabled"

    filter {} # applies to all objects in the bucket

    noncurrent_version_expiration {
      newer_noncurrent_versions = 15
      noncurrent_days            = 1
    }
  }
}