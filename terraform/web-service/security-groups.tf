#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ALB: EC2 Security Group
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_security_group" "website_lb" {
  count       = var.create && var.create_website ? 1 : 0
  name        = "${var.stack}-${var.stage}-${var.region}-alb"
  description = "ALB service port rule"
  vpc_id      = data.terraform_remote_state.site.outputs.vpc_id

  ingress {
    from_port   = var.target_group_listening_port
    to_port     = var.target_group_listening_port
    protocol    = "tcp"
    cidr_blocks = var.public_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# website: EC2 Security Group
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_security_group" "website" {
  count       = var.create && var.create_website ? 1 : 0
  name        = "${var.stack}-${var.stage}-${var.region}-ec2"
  description = "ALB target group service port rule"
  vpc_id      = data.terraform_remote_state.site.outputs.vpc_id

  ingress {
    from_port       = var.target_group_port
    to_port         = var.target_group_port
    protocol        = "tcp"
    security_groups = aws_security_group.website_lb.*.id
    cidr_blocks     = [var.vpc_network]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# website: ALB Targets Security Group
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_security_group" "website_backend" {
  count       = var.create && var.create_website ? 1 : 0
  name        = "${var.stack}-${var.stage}-${var.region}-ec2_backend"
  description = "EC2 service port rule"
  vpc_id      = data.terraform_remote_state.site.outputs.vpc_id

  ingress {
    from_port   = var.target_group_port
    to_port     = var.target_group_port
    protocol    = "tcp"
    cidr_blocks = data.aws_subnet.website_private_subnet_cidrs.*.cidr_block
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# website: EC2 Remote access Security Group
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_security_group" "website_admin" {
  count       = var.debug ? 1 : 0
  name        = "${var.stack}-${var.stage}-${var.region}-debug"
  description = "EC2 admin access rules"
  vpc_id      = data.terraform_remote_state.site.outputs.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.admin_cidr_blocks
  }

  ingress {
    from_port   = var.target_group_port
    to_port     = var.target_group_port
    protocol    = "tcp"
    cidr_blocks = var.admin_cidr_blocks
  }
}
