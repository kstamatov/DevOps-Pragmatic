resource "aws_alb" "alb" {  
  name            = "ALB-FARGATE-CHART"  
  subnets         = "${[aws_subnet.svc-public.id,aws_subnet.svc-public-2.id]}"
  security_groups = "${[aws_security_group.sg-2.id]}"
  idle_timeout    = 300
}

resource "aws_alb_listener" "alb_listener" {  
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = 80  
  protocol          = "HTTP"
  
  default_action {    
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    type             = "forward"  
  }
}

resource "aws_alb_listener_rule" "listener_rule" {
  depends_on   = ["aws_alb_target_group.alb_target_group"]  
  listener_arn = "${aws_alb_listener.alb_listener.arn}"
  priority     = 100
  action {    
    type             = "forward"    
    target_group_arn = "${aws_alb_target_group.alb_target_group.id}"  
  }   
  condition {    
    field  = "path-pattern"    
    values = ["/*"]  
  }
}

resource "aws_alb_target_group" "alb_target_group" {  
  name     = "TG-FARGATE-CHART"  
  port     = 8080  
  protocol = "HTTP"  
  vpc_id   = "${aws_vpc.svc-vpc.id}"
  target_type = "ip"
  health_check {    
    healthy_threshold   = 3    
    unhealthy_threshold = 10    
    timeout             = 5    
    interval            = 10    
    path                = "/"    
    port                = 8080  
  }
  depends_on = [aws_alb.alb]

}
