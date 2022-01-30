# Terraform bootstrap component

This module creates encrypted AWS bucket required for all Terraform components.

The local Terraform state is backed up to this bucket.

## Managed AWS services

  * S3 bucket for Terraform state
  * KMS for S3 bucket encryption
  * DynamoDB for Terraform state locking
  * IAM roles and policies
