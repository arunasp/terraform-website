#~~~~~~~~~~~~~~~~~~~~
# Website endpoints
#~~~~~~~~~~~~~~~~~~~~
output "website_bucket" {
  description = "Website S3 bucket"
  value       = element(concat([data.terraform_remote_state.site.outputs.website_bucket.*, ""]), 0)
}

output "alb_address" {
  description = "Application Load Balancer hostname"
  value       = element(concat([aws_lb.website.*.dns_name, ""]), 0)
}

output "web_address" {
  description = "Website URL"
  value       = "http://${join(", ", element(concat([aws_lb.website.*.dns_name, ""]), 0))}/"
}
