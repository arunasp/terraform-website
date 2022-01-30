#~~~~~~~~~~~~~
# Creational
#~~~~~~~~~~~~~
variable "create" {
  description = "Controls resource creation"
  default     = false
}

variable "is_instance_profile" {
  description = "Determines if the IAM role will be associated to an IAM instance profile"
  default     = false
}

#~~~~~~~
# Role
#~~~~~~~
variable "name" {
  description = "The name of the role"
  default     = ""
}

variable "path" {
  description = "Path under which the role resides"
  default     = "/"
}

variable "trust_policy" {
  description = "The trust policy for this role"
}

variable "role_policies" {
  type        = list(any)
  description = "A list of IAM policy ARNs to attach to this role"
  default     = []
}
