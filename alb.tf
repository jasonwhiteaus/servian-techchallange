#Create ALB
resource "aws_lb" "tc_alb" {
  name               = "tc-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tc_alb_secg.id]
  subnets            = toset(aws_subnet.tc_public_subnet_group.*.id)
}

resource "aws_lb_target_group" "tc_alb_tg" {
  name        = "tc-alb-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_lb_listener" "tc_alb_listener" {
  load_balancer_arn = aws_lb.tc_alb.arn
  port              = "3000"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tc_alb_tg.arn
  }
}

