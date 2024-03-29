# public security
resource "aws_security_group" "alb-sg" {
  vpc_id = var.vpc_id
  dynamic "ingress" {
    for_each = var.alb-ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge({Name = "${var.env}-alb-sg"}, var.tags)
}

resource "aws_security_group" "batch-sg" {
  vpc_id = var.vpc_id
  dynamic "ingress" {
    for_each = var.batch-ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge({Name = "${var.env}-batch-sg"}, var.tags)
}

# private security
resource "aws_security_group" "instance-sg" {
  vpc_id = var.vpc_id
  dynamic "ingress" {
    for_each = var.instance-ingress
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      security_groups = [aws_security_group.alb-sg.id]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge({Name = "${var.env}-instance-sg"}, var.tags)
}

# RDS security
resource "aws_security_group" "rds-sg" {
  vpc_id = var.vpc_id
  dynamic "ingress" {
    for_each = var.rds-ingress
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      security_groups = [aws_security_group.instance-sg.id]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge({Name = "${var.env}-rds-sg"}, var.tags)
}

# vpc-endpoint security
resource "aws_security_group" "endpoint-sg" {
  vpc_id = var.vpc_id
  dynamic "ingress" {
    for_each = var.endpoint-ingress
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      security_groups = [aws_security_group.instance-sg.id]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "TCP"
    security_groups = [aws_security_group.instance-sg.id]
  }

  tags = merge({Name = "${var.env}-endpoint-sg"}, var.tags)
}