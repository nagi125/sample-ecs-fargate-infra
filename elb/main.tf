variable "app_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

resource "aws_security_group" "main" {
  name        = "${var.app_name}-alb"
  description = "${var.app_name} alb"

  vpc_id = var.vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-alb"
  }
}

resource "aws_security_group_rule" "http" {
  security_group_id = aws_security_group.main.id

  type = "ingress"

  from_port = 80
  to_port   = 80
  protocol = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_lb" "main" {
  load_balancer_type = "application"
  name               = var.app_name

  security_groups = [aws_security_group.main.id]
  subnets = var.public_subnet_ids
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn

  port = 80
  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "ok"
    }
  }
}

output "http_listener_arn" {
  value = aws_lb_listener.http.arn
}