#~~~~~~~
# Site
#~~~~~~~
output "site_kms_key_arn" {
  value = module.aws_site_kms.arn.0
}

output "site_kms_key_id" {
  value = module.aws_site_kms.kms_key_id.0
}

output "website_bucket" {
  value = module.s3_website.bucket
}

#~~~~~~
# VPC
#~~~~~~
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}
