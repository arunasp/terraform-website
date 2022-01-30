#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Site Terraform S3 Remote State
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
data "terraform_remote_state" "site" {
  backend = "s3"

  config = {
    bucket = "${var.stack}-${var.stage}-${var.region}-terraform-state"
    key    = "site/terraform.tfstate"
    region = "${var.region}"
  }
}
