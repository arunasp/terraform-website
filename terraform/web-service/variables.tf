#~~~~~~
# DNS
#~~~~~~
variable "hosted_zone_name" {
  description = "Name to use for the hosted zone"
  default     = "local"
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Application Load Balancer
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
variable "alb_subnet_ids" {
  description = "A list of Subnet ID's for the Load Balancer to load balance across"
  type        = list(any)
  default     = []
}

#~~~~~~~~~~~~~~~
# Target Group
#~~~~~~~~~~~~~~~
variable "target_vpc_id" {
  description = "The VPC ID where the Target Group resides"
  default     = ""
}

variable "target_group_listening_port" {
  description = "website LB listening port"
  default     = 80
}

variable "target_group_port" {
  description = "Port over which traffice is directed to the Target Group on"
  default     = 80
}

variable "health_check_port" {
  description = "Port over which health checks are conducted"
  default     = 80
}

#~~~~~~~~~~~~~~~~~~~~~~~
# Launch Configuration
#~~~~~~~~~~~~~~~~~~~~~~~
variable "ami_id" {
  description = "AMI to use for each EC2 instance"
  default     = "ami-0015a39e4b7c0966f" # Ubuntu Server 20.04 LTS 
}

variable "instance_type" {
  description = "The EC2 instance type to launch"
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "Name of the key pair to apply to the instance"
  default     = ""
}

variable "user_data" {
  description = "User Data for each EC2 instance"
  default     = ""
}

#~~~~~~~~~~~~~~~~~~~~
# Autoscaling Group
#~~~~~~~~~~~~~~~~~~~~
variable "asg_max_size" {
  description = "Max size of the Autoscaling Group"
  default     = 1
}

variable "asg_min_size" {
  description = "Min size of the Autoscaling Group"
  default     = 1
}

variable "asg_desired_capacity" {
  description = "Desired capacity of the Autoscaling Group"
  default     = 1
}

variable "asg_subnet_ids" {
  description = "A list of subnet IDs to launch resources in"
  type        = list(any)
  default     = []
}

#~~~~~~~~~~~~~~~~~~
# Security Groups
#~~~~~~~~~~~~~~~~~~
variable "permitted_security_group_ids" {
  description = "A list of security group IDs that are permitted to be the source for sending traffic to the website Load Balancer"
  type        = list(any)
  default     = []
}

#~~~~~~
# IAM
#~~~~~~
variable "kms_key_id" {
  description = "ID of the KMS Key to grant access to"
  default     = ""
}

#~~~~~~~~~~~~~~~~~~~~~~~~
# Troubleshoting access
#~~~~~~~~~~~~~~~~~~~~~~~~
variable "debug" {
  description = "Troubleshoting Access"
  default     = true
}
