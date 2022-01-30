data "aws_availability_zones" "available" {}

resource "aws_security_group" "website_endpoint" {
  count  = "0"
  name   = "website-endpoint"
  vpc_id = module.vpc.vpc_id
  #  tags   = "${merge(var.default_tags, map("Name", "sg-ecr-endpoint"))}"
}

resource "aws_security_group_rule" "website_endpoint_inbound" {
  count             = "0"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["172.20.0.0/21"]
  security_group_id = aws_security_group.website_endpoint[0].id
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.4"

  create_vpc = var.create_vpc

  name = "${var.stack}-${var.stage}"
  tags = var.default_tags

  azs  = data.aws_availability_zones.available.names
  cidr = var.vpc_network

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  enable_nat_gateway = true
  enable_vpn_gateway = false
  single_nat_gateway = true
}
