provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    key            = "site/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
