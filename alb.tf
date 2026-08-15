# alb.tf

resource "aws_lb" "main" {
  name               = "${local.name}-alb"
  load_balancer_type = "application"

  subnets = module.vpc.public_subnets

  security_groups = [
    aws_security_group.alb.id
  ]

  enable_deletion_protection = true

  tags = local.common_tags
}


resource "aws_lb_target_group" "app" {
  name        = "${local.name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    enabled = true

    path = "/health"

    protocol = "HTTP"

    matcher = "200"

    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = local.common_tags
}
