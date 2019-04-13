# PlayQ Engineering Exercise

The questions below reflect some of the key roles and responsibilities you will be asked to execute and perform here on the Engineering team here at PlayQ.

Once you review and complete the exercise below, please share your answers in the form of a link to your public GitHub repo.

## Instructions

The goal of this exercise is to use Terraform to provision an AWS Autoscaling Group, and Application Load Balancer in AWS us-east-1 region. All instances created by the autoscaling group should have some security group rules defined below and also bootstrap using the userdata.sh file. You can use any flavor of Linux for your instances but pay close attention to requirements related to being able to find the correct AMI based on the AWS region.

The end result should be a public GitHub repo with four files:

* [loadbalancer.tf](loadbalancer.tf)
* [autoscaling.tf](autoscaling.tf)
* [userdata.sh](userdata.sh)
* [variables.tf](variables.tf)

You should be able to find documentation for both Terraform and AWS through Google but these links might be useful in getting started:

* [Terraform AWS Provider Docs](https://www.terraform.io/docs/providers/aws/index.html)
* [AWS Guides and API References](https://docs.aws.amazon.com/#lang/en_us)

When writing the Terraform code it might be a good idea to test your code. Everything in this challenge should be within AWS’s free tier of services for new accounts. If you wish to test your code before submitting it sign up for a new AWS account.

The following are requirements for the deployment:

* All instances created by the Autoscaling Group should

    * Use an SSH key pair named "webservers"
    * Have a `Name` tag with a value of "PlayQ-2019"
    * Have a `Type` tag with a value of "webserver"
    * Use the `t2.micro` instance type
    * Set the `user_data` of the instance to the [userdata.sh](userdata.sh) file content (see below)
    * Attach a security group (see below)

* The Autoscaling Group and Launch Configuration should

    * Choose the correct AMI based upon the region it’s launching into (hint: the Terraform `lookup` interpolation function will help)
    * Have a `Name` tag with a value of `PlayQ-2019`
    * Have a `Type` tag with a value of `webserver`

* The Application Load Balancer should:

    * Return a fix 500 code by default
    * Use the host header to direct requests for "www.playqtest.com" to the Auto Scaling Group instances

* Attach a security group (see below)
    
    * The Security Group for the instances should
    * Allow inbound SSH from your IP
    * Allow inbound SSH from `76.169.181.157`
    * The Security Group for the Load Balancer should
    * Allow inbound HTTP from everywhere
    * Allow all outbound traffic to everywhere

* The [userdata.sh](userdata.sh) Script should
    
    * Use the appropriate package manager to install the apache2 webserver

## Usage

Assuming you have:
    * [`terraform`](https://www.terraform.io/) version *0.11.13* installed on your machine 
    * A 4096-bit RSA SSH keypair available at `/var/tmp/` with names `webserverkey[.pub]`
    * and an AWS account with appropriate credentials

You'll need to:
    * Source in your AWS credentials (and have them exported as the appropriate environment variables)
    * Validate the terraform configs with `terraform validate`
    * Initialize terraform with `terraform init`
    * See what changes will take place with `terraform plan`
    * Execute the plan of action with `terraform apply`

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| access\_key\_id | AWS Access Key ID. You may set this as an env var called `TF_VAR_access_key_id` | string | `""` | no |
| ami\_name\_filter | AMI Name Filter. More info: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html | string | `"ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server"` | no |
| ami\_owner\_account\_id | AWS Account Owner ID for the AMI owner | string | `"099720109477"` | no |
| asg\_desired\_instances | The minimum size of the auto scaling group | string | `"1"` | no |
| asg\_max\_instances | The maximum size of the auto scaling group | string | `"2"` | no |
| asg\_min\_instances | The number of Amazon EC2 instances that should be running in the auto scaling group | string | `"1"` | no |
| ec2\_instance\_type | EC2 Instance Type. More info: https://aws.amazon.com/ec2/instance-types/ | string | `"t2.micro"` | no |
| ec2\_name\_tag | EC2 tag for the Name attribute | string | `"PlayQ-2019"` | no |
| ec2\_type\_tag | EC2 tag for the Type attribute | string | `"webserver"` | no |
| host\_header\_value | Where to redirect request based on host based routing | string | `"www.playqtest.com"` | no |
| http\_port | HTTP Port | string | `"80"` | no |
| region | AWS Region. More info: https://aws.amazon.com/about-aws/global-infrastructure/ | string | `"us-east-1"` | no |
| secret\_access\_key | AWS Secret Access Key. You may set this as an env var called `TF_VAR_secret_access_key` | string | `""` | no |
| ssh\_key\_pair\_name | SSH Key Pair Name | string | `"webservers"` | no |
| ssh\_port | SSH Port | string | `"22"` | no |
| ssh\_public\_key\_path | Path to public SSH key on the machine | string | `"/var/tmp/webserverkey.pub"` | no |
| use\_most\_recent\_ami | Use the most recent AMI for the filters corresponding to `ami_name_filter` and `ami_owner_account_id`? | string | `"true"` | no |
| user\_data\_script | Location of the userdata script | string | `"./userdata.sh"` | no |
| whitelisted\_ips | A list of whitelisted IPs for SSH access (besides your own) | list | `<list>` | no |

## Other information

* Table of vars created with [`terraform-docs`](https://github.com/segmentio/terraform-docs)
* Code formatting done with `terraform fmt`
* Made with :heart: for the [PlayQ](https://www.playq.com/) Engineering Exercise
