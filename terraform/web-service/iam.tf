#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Website Instance IAM Profile
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
module "iam_website" {
  count  = var.create && var.create_website ? 1 : 0
  source = "../modules/iam-role/"

  create              = var.create
  is_instance_profile = true
  name                = "${var.stack}-${var.stage}-${var.region}-instance-profile"
  trust_policy        = data.template_file.website_iam_trust_policy.rendered
  role_policies       = [data.template_file.website_iam_role_policy.rendered, data.template_file.website_s3_role_policy.rendered, data.aws_iam_policy.AmazonEC2RoleforSSM.policy]
}
