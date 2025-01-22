resource "aws_lb" "this" {
  name               = "${local.prefix}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.alb_sg.security_group_id]
  subnets            = [for value in aws_subnet.public_subnet : value.id]

  tags = {
    Name = "${local.prefix}-lb"
  }
}

resource "aws_lb_target_group" "this" {
  name   = "${local.prefix}-tg"
  vpc_id = aws_vpc.main_vpc.id

  target_type = "ip"
  protocol    = "HTTP"
  port        = 80
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  protocol          = "HTTPS"
  port              = 443
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = module.acm.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}