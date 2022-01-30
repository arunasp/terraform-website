resource "aws_s3_bucket" "this" {
  count = var.create && length(var.users) > 0 ? 1 : 0

  bucket = var.name
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle_rule {
    prefix  = "*"
    enabled = true

    noncurrent_version_expiration {
      days = var.version_expiration_days
    }
  }

  force_destroy = true

}

resource "aws_s3_bucket_policy" "this" {
  count = var.create && length(var.users) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this[count.index].id
  policy = data.template_file.this_bucket_policy[count.index].rendered
}
