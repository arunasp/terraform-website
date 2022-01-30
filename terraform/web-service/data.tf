#~~~~~~~~~~~~~~~~~~~~
# EC2 Init script
#~~~~~~~~~~~~~~~~~~~~
data "template_file" "website_user_data" {
  template = file("${path.module}/init/user-data.tpl")

  vars = {
    aws_account_id   = var.account_id
    aws_region       = var.region
    instance_profile = "${var.stack}-${var.stage}-${var.region}-instance-profile"
    website_bucket   = data.terraform_remote_state.site.outputs.website_bucket.0
  }
}

#~~~~~~~~~~~~~~~~~~~~
# EC2 SSH Public Key
#~~~~~~~~~~~~~~~~~~~~
data "template_file" "ssh_public_key" {
  template = file("../../ec2_key.pub")
}

#~~~~~~~~~~~~~~~~~~~~
# VPC data
#~~~~~~~~~~~~~~~~~~~~
data "aws_subnet" "website_private_subnet_cidrs" {
  count = length(data.terraform_remote_state.site.outputs.private_subnets)
  id    = element(data.terraform_remote_state.site.outputs.private_subnets, count.index)
}

data "aws_subnet" "website_public_subnet_cidrs" {
  count = length(data.terraform_remote_state.site.outputs.public_subnets)
  id    = element(data.terraform_remote_state.site.outputs.public_subnets, count.index)
}

#~~~~~~~~~~~~~~~~~~~~
# IAM policies
#~~~~~~~~~~~~~~~~~~~~
data "template_file" "website_iam_role_policy" {
  template = file("${path.module}/policy-documents/website-instance-profile/role-policy.json.tpl")

  vars = {
    aws_account_id   = var.account_id
    aws_region       = var.region
    instance_profile = "${var.stack}-${var.stage}-${var.region}-instance-profile"
    kms_key_id       = var.kms_key_id
  }
}

data "template_file" "website_iam_trust_policy" {
  template = file("${path.module}/policy-documents/website-instance-profile/trust-policy.json.tpl")
}

data "template_file" "website_s3_role_policy" {
  template = file("${path.module}/policy-documents/website-instance-profile/s3-policy.json.tpl")

  vars = {
    website_bucket = data.terraform_remote_state.site.outputs.website_bucket.0
  }
}

data "aws_iam_policy" "AmazonEC2RoleforSSM" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
