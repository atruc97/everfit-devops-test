data "aws_lb" "existing" {
  name = "everfit-app-alb"
}

data "aws_lb_target_group" "existing" {
  name = "everfit-app-tg"
}

data "aws_lb_listener" "https" {
  load_balancer_arn = data.aws_lb.existing.arn
  port              = 443
}

data "aws_lb_listener" "http" {
  load_balancer_arn = data.aws_lb.existing.arn
  port              = 80
}

