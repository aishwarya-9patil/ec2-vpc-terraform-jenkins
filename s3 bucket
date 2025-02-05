# Create an S3 bucket
resource "aws_s3_bucket" "example_bucket" {
  # Use a unique bucket name, since S3 bucket names must be globally unique
  bucket = "aishu-bucket-${random_id.bucket_suffix.hex}"  # Use a unique suffix to avoid conflicts
  acl    = "private"

  # Tags for the bucket
  tags = {
    Environment = "Dev"
    Name        = "Example S3 Bucket"
  }
}

# Generate a random suffix to append to the bucket name (to ensure uniqueness)
resource "random_id" "bucket_suffix" {
  byte_length = 8  # 8-byte random ID for uniqueness
}

# Enable versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
