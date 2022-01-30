output "arn" {
  description = "The ARN of the KMS key"
  value       = element(concat([aws_kms_key.this.*.arn, ""]), 0)
}

output "kms_key_id" {
  description = "The ARN of the KMS key"
  value       = element(concat([aws_kms_key.this.*.id, ""]), 0)
}
