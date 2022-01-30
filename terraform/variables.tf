#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Creational conditional variables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Site
variable "create" {
  description = "Controls global resource creation"
  type        = bool
  default     = false
}

variable "create_default_resources" {
  description = "Controls creation of the default resources in the account"
  default     = true
}

variable "create_terraform_state_resources" {
  description = "Controls creation of the resources used to manage terraform remote state"
  default     = true
}

variable "create_site" {
  description = "Controls site creation"
  default     = false
}

variable "create_vpc" {
  description = "Controls VPC creation"
  default     = true
}

variable "create_public_dns_zone" {
  description = "Controls creation of public DNS resources"
  default     = false
}

# Service
variable "create_website" {
  description = "Controls the creation of the website"
  default     = true
}

#~~~~~~~~~~~~~~~~
# Cross Cutting
#~~~~~~~~~~~~~~~~
variable "stack" {
  description = "The name of the service"
  default     = "website"
}

variable "stage" {
  description = "The name of the stage. Typically refers to the Git project branch name"
  default     = "dev"
}

variable "region" {
  description = "The AWS region where the resources will be deployed"
  default     = "eu-west-2"
}

variable "account_id" {
  description = "The AWS account where the resuorces will be deployed"
  default     = ""
}

variable "default_tags" {
  description = "A set of tags that will be applied to all resources"
  type        = map(any)
  default     = {}
}

variable "vpc_network" {
  description = "VPC network allocation"
  default     = "172.16.0.0/21"
}

variable "private_subnets" {
  description = "VPC private networks"
  type        = list(any)
  default     = ["172.16.1.0/26", "172.16.2.0/26"]
}

variable "public_subnets" {
  description = "VPC public networks"
  type        = list(any)
  default     = ["172.16.3.0/26", "172.16.4.0/26"]
}

variable "public_cidr_blocks" {
  description = "Applocation Load balancer public  access networks whitelist"
  type        = list(any)
  default     = ["0.0.0.0/0"]
}

variable "admin_cidr_blocks" {
  description = "Remote administrative access networks whitelist"
  type        = list(any)
  default     = ["127.0.0.0/8"]
}
