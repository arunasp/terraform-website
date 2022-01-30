#~~~~~~~~~~~~~
# Creational
#~~~~~~~~~~~~~
variable "create" {
  description = "Controls resource creation"
  type        = bool
  default     = false
}

#~~~~~~~~~~~~
# S3 Bucket
#~~~~~~~~~~~~
variable "name" {
  description = "The name of the bucket"
  default     = ""
}

variable "stack" {
  description = "The name of the service"
  default     = "stack"
}

variable "stage" {
  description = "The name of the stage.  Typically refers to the GitHub project"
  default     = "stage"
}

variable "region" {
  description = "The AWS region where the resources will be deployed"
  default     = "eu-west-2"
}


variable "kms_key_arn" {
  description = "KMS Key ARN to encrypt the bucket"
  default     = "arn:aws:kms:us-west-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
}

variable "users" {
  description = "IAM users for bucket access"
  default     = ["arn:aws:iam::*:root"]
  type        = list(any)
}

variable "version_expiration_days" {
  description = "Number of days after which historical versions will be deleted"
  default     = 180
}
