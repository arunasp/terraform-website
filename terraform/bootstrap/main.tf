module "aws_kms_key" {
  count  = var.create && var.create_terraform_state_resources ? 1 : 0
  source = "../modules/kms/"

  create     = var.create && var.create_default_resources ? true : false
  name       = "${var.stack}-${var.stage}-${var.region}-terraform-key"
  stack      = var.stack
  stage      = var.stage
  account_id = var.account_id
}

module "s3_terraform" {
  source = "../modules/s3-bucket/"

  create = var.create && var.create_default_resources ? true : false
  name   = "${var.stack}-${var.stage}-${var.region}-terraform-state"

  kms_key_arn             = element(concat([module.aws_kms_key.0.arn.0, ""]), 0)
  users                   = ["arn:aws:iam::${var.account_id}:root"]
  version_expiration_days = 180
}

resource "aws_dynamodb_table" "terraform_statelock" {
  count = var.create && var.create_terraform_state_resources ? 1 : 0

  name           = "terraform-lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Origin = "Terraform"
  }
}

resource "aws_s3_bucket_object" "tf_state_upload" {
  depends_on = [module.s3_terraform]
  bucket     = "${var.stack}-${var.stage}-${var.region}-terraform-state"
  key        = "bootstrap/terraform.tfstate"
  source     = "${path.module}/terraform.tfstate"
}

resource "aws_s3_bucket_object" "tf_state_backup_upload" {
  depends_on = [module.s3_terraform]
  bucket     = "${var.stack}-${var.stage}-${var.region}-terraform-state"
  key        = "bootstrap/terraform.tfstate.backup"
  source     = "${path.module}/terraform.tfstate"
}
