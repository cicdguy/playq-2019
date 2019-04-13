variable "access_key_id" {
  description = "AWS Access Key ID. You may set this as an env var called `TF_VAR_access_key_id`"
  default     = ""
  type        = "string"
}

variable "secret_access_key" {
  description = "AWS Secret Access Key. You may set this as an env var called `TF_VAR_secret_access_key`"
  default     = ""
  type        = "string"
}

variable "region" {
  description = "AWS Region. More info: https://aws.amazon.com/about-aws/global-infrastructure/"
  default     = "us-east-1"
  type        = "string"
}

variable "ssh_key_pair_name" {
  description = "SSH Key Pair Name"
  default     = "webservers"
  type        = "string"
}

variable "ssh_public_key_path" {
  description = "Path to public SSH key on the machine"
  default     = "/var/tmp/webserverkey.pub"
  type        = "string"
}

variable "ec2_instance_type" {
  description = "EC2 Instance Type. More info: https://aws.amazon.com/ec2/instance-types/"
  default     = "t2.micro"
  type        = "string"
}

variable "ec2_name_tag" {
  description = "EC2 tag for the Name attribute"
  default     = "PlayQ-2019"
  type        = "string"
}

variable "ec2_type_tag" {
  description = "EC2 tag for the Type attribute"
  default     = "webserver"
  type        = "string"
}

variable "whitelisted_ips" {
  description = "A list of whitelisted IPs for SSH access (besides your own)"
  type        = "list"
  default     = ["76.169.181.157/32"]
}

variable "ssh_port" {
  description = "SSH Port"
  default     = 22
}

variable "user_data_script" {
  description = "Location of the userdata script"
  default     = "./userdata.sh"
  type        = "string"
}

variable "asg_min_instances" {
  description = "The number of Amazon EC2 instances that should be running in the auto scaling group"
  default     = 1
}

variable "asg_max_instances" {
  description = "The maximum size of the auto scaling group"
  default     = 2
}

variable "asg_desired_instances" {
  description = "The minimum size of the auto scaling group"
  default     = 1
}

variable "http_port" {
  description = "HTTP Port"
  default     = 80
}

variable "ami_name_filter" {
  description = "AMI Name Filter. More info: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html"
  default     = "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server"
  type        = "string"
}

variable "ami_owner_account_id" {
  description = "AWS Account Owner ID for the AMI owner"
  default     = "099720109477"                           # Canonical
  type        = "string"
}

variable "use_most_recent_ami" {
  description = "Use the most recent AMI for the filters corresponding to `ami_name_filter` and `ami_owner_account_id`?"
  default     = true
}

variable "host_header_value" {
  description = "Where to redirect request based on host based routing"
  default     = "www.playqtest.com"
  type        = "string"
}
