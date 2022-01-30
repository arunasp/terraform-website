# AWS Site component

This module creates VPC and encrypted website S3 bucket in AWS.
The Site component is designed for static AWS services such as networking and shared resources like S3 buckets.

The Terraform remote state is using S3 bucket from bootstrap component for colaboration.

## Managed AWS services

  * S3 bucket for website content
  * KMS for website S3 bucket encryption
  * VPC services for EC2 and ALB
  * DynamoDB for Terraform state locking
  * IAM roles and policies for VPC, KMS and S3

## Used AWS services

  * S3 bucket for Terraform state
  * KMS for S3 Terraform state bucket encryption
  * IAM roles and policies for Terraform state S3 and KMS


## TODO

  * Add Route53 customer DNS domain management
  * Add AWS cross-account delegation when required
  * Add AWS EC2 custom AMI management
