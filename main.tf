resource "aws_security_group" "main" {
  name        = var.internal ? "${var.env}-int-lb-sg" : "${var.env}-pub-lb-sg"
  description = var.internal ? "${var.env}-int-lb-sg" : "${var.env}-pub-lb-sg"
  vpc_id      = var.internal ?  var.vpc_id : var.default_vpc_id
  tags        = merge(local.tags , { Name = var.internal ? "${var.env}-int-lb-sg" : "${var.env}-pub-lb-sg" })

  ingress {
    description = "APP"
    from_port   = var.sg_port
    to_port     = var.sg_port
    protocol    = "tcp"
    cidr_blocks = var.sg_ingress_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }

}

resource "aws_lb" "main" {
  name               = var.internal ? "${var.env}-int-lb" : "${var.env}-pub-lb"
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  security_groups    = [aws_security_group.main.id]
  subnets            = var.subnets
  tags               = merge(local.tags , { Name = var.internal ? "${var.env}-int-lb" : "${var.env}-pub-lb" })

}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Can you try with HostHeader"
      status_code  = "404"
    }
  }
}