module "aws_site_kms" {
  source = "../modules/kms/"

  create     = var.create && var.create_default_resources ? true : false
  name       = "${var.stack}-${var.stage}-${var.region}-site-key"
  stack      = var.stack
  stage      = var.stage
  account_id = var.account_id
}

module "s3_website" {
  source = "../modules/s3-bucket/"

  create = var.create && var.create_default_resources ? true : false
  name   = "${var.stack}-${var.stage}-${var.region}-website"

  kms_key_arn             = element(concat([module.aws_site_kms.arn.0, ""]), 0)
  users                   = ["arn:aws:iam::${var.account_id}:root"]
  version_expiration_days = 180
}
