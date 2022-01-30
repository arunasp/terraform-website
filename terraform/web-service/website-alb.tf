#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Application Load Balancer
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_lb" "website" {
  count              = var.create && var.create_website ? 1 : 0
  name               = "${var.stack}-${var.stage}"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.website_lb.0.id]
  subnets         = data.aws_subnet.website_public_subnet_cidrs.*.id

  lifecycle {
    create_before_destroy = false
  }
}

#~~~~~~~~~~~~~~~
# Target Group
#~~~~~~~~~~~~~~~
resource "aws_lb_target_group" "website" {
  count       = var.create && var.create_website ? 1 : 0
  name        = "${var.stack}-${var.stage}-${var.region}"
  protocol    = "HTTP"
  port        = var.target_group_port
  target_type = "instance"
  vpc_id      = data.terraform_remote_state.site.outputs.vpc_id

  health_check {
    path                = "/alb_healthcheck.txt"
    port                = var.health_check_port
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 6
    interval            = 60
    matcher             = "200"
  }

  lifecycle {
    create_before_destroy = true
  }
}

#~~~~~~~~~~~
# Listener
#~~~~~~~~~~~
resource "aws_lb_listener" "website" {
  count             = var.create && var.create_website ? 1 : 0
  load_balancer_arn = aws_lb.website.0.arn
  protocol          = "HTTP"
  port              = var.target_group_listening_port

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.website.0.arn
  }

  lifecycle {
    create_before_destroy = true
  }
}


#~~~~~~~~~~~~~~~~~~~~
# Autoscaling Group
#~~~~~~~~~~~~~~~~~~~~
resource "aws_autoscaling_group" "website" {
  count       = var.create && var.create_website ? 1 : 0
  name_prefix = "${var.stack}-${var.stage}-${var.region}-asg"

  max_size         = var.asg_max_size
  min_size         = var.asg_min_size
  desired_capacity = var.asg_desired_capacity

  health_check_grace_period = 600
  health_check_type         = "ELB"

  launch_template {
    id      = aws_launch_template.website.0.id
    version = "$Latest"
  }
  target_group_arns = aws_lb_target_group.website.*.arn

  vpc_zone_identifier = data.aws_subnet.website_public_subnet_cidrs.*.id

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "Cluster"
      value               = "${var.stack}-${var.stage}"
      propagate_at_launch = true
    },
  ]
}
