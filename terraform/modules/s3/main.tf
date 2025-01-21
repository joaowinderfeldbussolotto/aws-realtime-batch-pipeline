resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  force_destroy = true  # Allow terraform destroy to remove bucket with contents
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}



