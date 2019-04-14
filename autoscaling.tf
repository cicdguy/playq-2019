# _____ _____ _____ _   _______ 
#/  ___|  ___|_   _| | | | ___ \
#\ `--.| |__   | | | | | | |_/ /
# `--. \  __|  | | | | | |  __/
#/\__/ / |___  | | | |_| | |
#\____/\____/  \_/  \___/\_|

# Set the provider
provider "aws" {
  version = "~> 2.4.0"

  access_key = "${var.access_key_id}"
  secret_key = "${var.secret_access_key}"
  region     = "${var.region}"
}

resource "aws_key_pair" "webserver-ssh-key" {
  key_name   = "${var.ssh_key_pair_name}"
  public_key = "${file(var.ssh_public_key_path)}"
}

# Use the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get the all subnets in the default VPC
data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Get all availability zones for the given region
data "aws_availability_zones" "available" {}

# Shameless plug from
# https://stackoverflow.com/questions/46763287/i-want-to-identify-the-public-ip-of-the-terraform-execution-environment-and-add?answertab=votes#tab-top
data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
}

# Append current IP to other whitelisted IPs
locals {
  my_ip           = "${chomp(data.http.my_ip.body)}/32"
  whitelisted_ips = "${concat(var.whitelisted_ips, list(local.my_ip))}"
  rc_name_prefix  = "${var.ec2_name_tag}-${var.ec2_type_tag}"
}

# AMI IDs
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html
data "aws_ami" "latest_ami" {
  most_recent = "${var.use_most_recent_ami}"

  filter {
    name   = "name"
    values = ["${var.ami_name_filter}-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  owners = ["${var.ami_owner_account_id}"]
}

# _       ___  _   _ _   _ _____  _   _      _____ _____ _   _ ______ _____ _____ 
#| |     / _ \| | | | \ | /  __ \| | | |   /  __ \  _  | \ | ||  ___|_   _|  __ \
#| |    / /_\ \ | | |  \| | /  \/| |_| |   | /  \/ | | |  \| || |_    | | | |  \/
#| |    |  _  | | | | . ` | |    |  _  |   | |   | | | | . ` ||  _|   | | | | __ 
#| |____| | | | |_| | |\  | \__/\| | | |   | \__/\ \_/ / |\  || |    _| |_| |_\ \
#\_____/\_| |_/\___/\_| \_/\____/\_| |_/    \____/\___/\_| \_/\_|    \___/ \____/
# Create a security group for SSH access to the EC2 instances
resource "aws_security_group" "webserver-sg" {
  name        = "${local.rc_name_prefix}-ssh-sg"
  description = "Web Server SSH Access Security Group"

  ingress {
    from_port   = "${var.ssh_port}"
    to_port     = "${var.ssh_port}"
    protocol    = "tcp"
    cidr_blocks = ["${local.whitelisted_ips}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating Launch Configuration for ASG
resource "aws_launch_configuration" "webserver-lc" {
  name            = "${local.rc_name_prefix}-lc"
  image_id        = "${data.aws_ami.latest_ami.id}"
  instance_type   = "${var.ec2_instance_type}"
  security_groups = ["${aws_security_group.webserver-sg.name}"]
  key_name        = "${aws_key_pair.webserver-ssh-key.key_name}"
  user_data       = "${file(var.user_data_script)}"

  lifecycle {
    create_before_destroy = true
  }
}

#  ___   _____ _____ 
# / _ \ /  ___|  __ \
#/ /_\ \\ `--.| |  \/
#|  _  | `--. \ | __ 
#| | | |/\__/ / |_\ \
#\_| |_/\____/ \____/

## Creating AutoScaling Group
resource "aws_autoscaling_group" "webserver-asg" {
  name_prefix          = "${local.rc_name_prefix}-"
  launch_configuration = "${aws_launch_configuration.webserver-lc.id}"

  # High availabilty for across all availability zones for the region
  availability_zones = ["${data.aws_availability_zones.available.names}"]
  min_size           = "${var.asg_min_instances}"
  max_size           = "${var.asg_max_instances}"
  desired_capacity   = "${var.asg_desired_instances}"

  load_balancers    = ["${aws_alb.webserver-alb.name}"]
  health_check_type = "EC2"
  force_delete      = true

  tags = [
    {
      key                 = "Name"
      value               = "${var.ec2_name_tag}"
      propagate_at_launch = true
    },
    {
      key                 = "Type"
      value               = "${var.ec2_name_tag}"
      propagate_at_launch = true
    },
  ]
}
