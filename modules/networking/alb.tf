resource "aws_security_group" "my_sg" {
  name = "my-sg"
  description = "Terraform security group"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb_target_group" "my_tg" {
  name = "my-tg"
  port = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = aws_vpc.main.id
}
resource "aws_lb" "my_alb" {
  name = "my-alb"
  load_balancer_type = "application"
#   subnets = ["${aws_subnet.public[0].id}","${aws_subnet.public[1].id}"]
  subnets     = [for subnet in aws_subnet.public : subnet.id]
  security_groups = ["${aws_security_group.my_sg.id}"]
}

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port = 80
  protocol = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_tg.arn
  }
}