locals {
  my_listeners = {
    "https" = {
      load_balancer_arn = aws_lb.main-alb.arn
      port              = var.lb-listen-port
      protocol          = var.lb-listen-protocol
      certificate_arn   = var.certificate_arn
    } ,
    "http" = {
      load_balancer_arn = aws_lb.main-alb.arn
      port              = var.lb-listen-port
      protocol          = var.lb-listen-protocol
      certificate_arn   = null
    }
  }
}

# define application load balancer
resource "aws_lb" "main-alb" {
  name               = "main-alb"
  internal           = false
  subnets            = var.alb-public-subnet-ids
  security_groups    = var.alb-sg-ids
  load_balancer_type = "application"

  tags = merge({Name = "${var.env}-main-alb"}, var.tags)
}


# Termination SSL/TLS
# define application load balancer - target-group
# v1 - blue
resource "aws_lb_target_group" "blue-target-group" {
  name        = "blue-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check
    matcher             = var.health_check_matcher
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health-check-count
    unhealthy_threshold = var.health-check-count
  }
}
# v2 - green
resource "aws_lb_target_group" "green-target-group" {
  name        = "green-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check
    matcher             = var.health_check_matcher
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health-check-count
    unhealthy_threshold = var.health-check-count
  }
}

# define application load balancer - listener
resource "aws_lb_listener" "alb-listener" {
  for_each = { for key, value in local.my_listeners: key => value if value.port == var.lb-listen-port }
  port              = each.value.port
  protocol          = each.value.protocol
  load_balancer_arn = each.value.load_balancer_arn
  certificate_arn   = each.value.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue-target-group.arn # default v1 - blue
  }
}

resource "aws_lb_listener_rule" "listener_rule" {
  listener_arn = var.lb-listen-port == 443 ? aws_lb_listener.alb-listener["https"].arn :aws_lb_listener.alb-listener["http"].arn
  action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.blue-target-group.arn
        weight = 100
      }

      target_group {
        arn    = aws_lb_target_group.green-target-group.arn
        weight = 0
      }
    }
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

resource "aws_lb_listener" "redirect" {
  count             = var.lb-listen-port == 443 ? 1 : 0
  load_balancer_arn = aws_lb.main-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
