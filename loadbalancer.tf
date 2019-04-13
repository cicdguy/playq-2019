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

# _____ ___  ______ _____  _____ _____    _____ ______ _____ _   _______ 
#|_   _/ _ \ | ___ \  __ \|  ___|_   _|  |  __ \| ___ \  _  | | | | ___ \
#  | |/ /_\ \| |_/ / |  \/| |__   | |    | |  \/| |_/ / | | | | | | |_/ /
#  | ||  _  ||    /| | __ |  __|  | |    | | __ |    /| | | | | | |  __/
#  | || | | || |\ \| |_\ \| |___  | |    | |_\ \| |\ \\ \_/ / |_| | |   
#  \_/\_| |_/\_| \_|\____/\____/  \_/     \____/\_| \_|\___/ \___/\_|
# Attach ALB to Target Group
resource "aws_alb_target_group" "webserver-tg" {
  name     = "${local.rc_name_prefix}-tg"
  port     = "${var.http_port}"
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.default.id}"
}

resource "aws_autoscaling_attachment" "webserver-asg-attachment" {
  alb_target_group_arn   = "${aws_alb_target_group.webserver-tg.arn}"
  autoscaling_group_name = "${aws_autoscaling_group.webserver-asg.id}"
}

# _     _____ _____ _____ _____ _   _  ___________ 
#| |   |_   _/  ___|_   _|  ___| \ | ||  ___| ___ \
#| |     | | \ `--.  | | | |__ |  \| || |__ | |_/ /
#| |     | |  `--. \ | | |  __|| . ` ||  __||    / 
#| |_____| |_/\__/ / | | | |___| |\  || |___| |\ \ 
#\_____/\___/\____/  \_/ \____/\_| \_/\____/\_| \_|
# Add listener to ALB
resource "aws_alb_listener" "webserver-alb-listener" {
  load_balancer_arn = "${aws_alb.webserver-alb.arn}"
  port              = "${var.http_port}"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.webserver-tg.arn}"
  }
}

# Add listener rule to ALB
resource "aws_alb_listener_rule" "webserver-listener-rule" {
  listener_arn = "${aws_alb_listener.webserver-alb-listener.arn}"
  priority     = 100

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Internal Server Error"
      status_code  = "500"
    }
  }

  condition {
    field  = "host-header"
    values = ["${var.host_header_value}"]
  }
}
