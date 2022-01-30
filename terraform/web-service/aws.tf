#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Website Terraform S3 State
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    key            = "web-service/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
