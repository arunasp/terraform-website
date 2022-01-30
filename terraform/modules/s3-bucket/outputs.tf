output "bucket" {
  description = "Name of the bucket"
  value       = element(concat([aws_s3_bucket.this.*.id, ""]), 0)
}
