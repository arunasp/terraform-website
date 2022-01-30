#~~~~~~~~~~~~~~~~~~~~~~~
# EC2 SSH key
#~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_key_pair" "ssh_key" {
  count      = var.create && var.create_website ? 1 : 0
  key_name   = "${var.stack}-${var.stage}-ssh-key"
  public_key = data.template_file.ssh_public_key.rendered
}


#~~~~~~~~~~~~~~~~~~~~~~~
# EC2 Launch Configuration
#~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_launch_template" "website" {
  count = var.create && var.create_website ? 1 : 0
  name  = "${var.stack}-${var.stage}"

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 50
    }
  }

  disable_api_termination = true
  ebs_optimized           = false

  iam_instance_profile {
    arn = module.iam_website.0.instance_profile_arn
  }

  image_id                             = var.ami_id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = var.instance_type
  key_name                             = aws_key_pair.ssh_key.0.key_name

  monitoring {
    enabled = true
  }

  vpc_security_group_ids = [aws_security_group.website.0.id, aws_security_group.website_backend.0.id, aws_security_group.website_admin.0.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      key                 = "website"
      value               = "${var.stack}-${var.stage}"
      propagate_at_launch = true
    }
  }

  user_data = length(var.user_data) > 0 ? var.user_data : base64encode(data.template_file.website_user_data.rendered)
}
