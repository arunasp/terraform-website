output "arn" {
  description = "The ARN of the IAM role"
  value       = element(concat([aws_iam_role.this.0.arn], [""]), 0)
}

output "instance_profile_arn" {
  description = "The ARN of the IAM instance profile"
  value       = element(concat([aws_iam_instance_profile.this.0.arn], [""]), 0)
}
