#  ___   _     ______ 
# / _ \ | |    | ___ \
#/ /_\ \| |    | |_/ /
#|  _  || |    | ___ \
#| | | || |____| |_/ /
#\_| |_/\_____/\____/

## ALB Security Group
resource "aws_security_group" "webserver-alb-sg" {
  name = "${local.rc_name_prefix}-alb-sg"

  ingress {
    from_port   = "${var.http_port}"
    to_port     = "${var.http_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### ALB Creation
resource "aws_alb" "webserver-alb" {
  name                       = "${local.rc_name_prefix}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = ["${aws_security_group.webserver-alb-sg.id}"]
  subnets                    = ["${data.aws_subnet_ids.all.ids}"]
  enable_deletion_protection = true
}
