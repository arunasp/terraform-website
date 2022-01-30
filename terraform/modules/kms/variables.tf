#~~~~~~~~~~~~~
# Creational
#~~~~~~~~~~~~~
variable "create" {
  description = "Controls resource creation"
  type        = bool
  default     = false
}

variable "create_default_resources" {
  description = "Controls creation of the default resources in the account"
  type        = bool
  default     = true
}

#~~~~~~~
# KMS
#~~~~~~~
variable "name" {
  description = "KMS key alias"
  default     = "kms-key"
}

variable "account_id" {
  description = "Account access for KMS"
  default     = "*"
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
