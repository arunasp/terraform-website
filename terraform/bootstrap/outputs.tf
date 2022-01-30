#~~~~~~~
# KMS and Terraform S3 bucket
#~~~~~~~

output "terraform_kms_key_arn" {
  value = module.aws_kms_key.0.arn
}

output "terraform_kms_key_id" {
  value = module.aws_kms_key.0.kms_key_id
}

output "terraform_bucket" {
  value = module.s3_terraform.bucket
}
