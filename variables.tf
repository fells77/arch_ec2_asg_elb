# Generic variables
variable "app_env" {
    description = "The environment (dev/qa/prod/...) you're deploying to"
    default = "dev"
}

variable "app_name" {
    description = "Your app name; use [a-zA-Z0-9_-] for best results"
}

variable "app_port" {
    description = "Port your application runs on"
}

variable "aws_region" {
    description = "The AWS region you're deploying to.  For example, 'us-east-1'"
}

variable "deployment_owner" {
    description = "Email/identifier of the person deploying this asset"
}

variable "owner_contact" {
    description = "Email/identifier of group supporting the application"
}
/*
variable "s3_bucket_name" {
    description = "Pre-existing S3 bucket for statefiles"
}
*/

# AWS infrastructure variables
variable "ami_id" {
    description = "The ID of the AMI you're using"
}

variable "asg_desired_size" {
    description = "Normal (BAU) # of instances in your autoscaling group"
    default = 1
}

variable "asg_max_size" {
    description = "Max # of instances in your autoscaling group"
    default = 1
}

variable "asg_min_size" {
    description = "Min # of instances in your autoscaling group"
    default = 1
}

variable "ebs_volume_size" {
    description = "EBS volume size (in GB)"
    default = 20
}

variable "ebs_volume_type" {
    description = "https://aws.amazon.com/ebs/volume-types/"
    default = "gp2"
}

variable "hc_healthy_threshold" {
    description = "ELB health check -- healthy threshold"
    default = 10
}

variable "hc_interval" {
    description = "ELB health check -- interval"
    default = 10
}

variable "hc_target" {
    description = "ELB health check -- target"
}

variable "hc_timeout" {
    description = "ELB health check -- timeout"
    default = 5
}

variable "hc_unhealthy_threshold" {
    description = "ELB health check -- unhealthy threshold"
    default = 2
}
/*
variable "iam_role" {
    description = "The IAM role your EC2 will use to connect to other services"
}
*/
variable "instance_type" {
    description = "https://aws.amazon.com/ec2/instance-types/"
    default = "m5.large"
}
/*
variable "listeners" {
    description = "Ingress port configurations for load balancer"
}
*/
variable "listener_port" {
    default = 3000
}

variable "listener_protocol" {
    default = "http"
}

variable "subnets" {
    description = "Subnet(s) for the ELB to leverage"
}

variable "user_data_path" {
    description = "EC2 data for build-time; should be path in project starting with /"
}

variable "vpc_id" {
    description = "VPC your subnets and security groups are contained in"
}
