# Generic variables
variable "app_name" {
    description = "Your app name; use [a-zA-Z0-9_-] for best results"
}

variable "aws_region" {
    description = "The AWS region you're deploying to.  For example, 'us-east-1'"
}

variable "ami_id" {
    description = "The ID of the AMI you're using"
}

variable "deploy_env" {
    description = "The environment (dev/qa/prod/...) you're deploying to"
}

variable "s3_bucket_name" {
    description = "Pre-existing S3 bucket for statefiles"
}

variable "tag_owner_contact" {
    description = "Email/identifier of group supporting the application"
}

variable "tag_deployment_owner" {
    description = "Email/identifier of the person deploying this asset"
}

# AWS infrastructure variables
variable "asg_max_size" {
    default = 1
}

variable "asg_min_size" {
    default = 1
}

variable "asg_desired_size" {
    default = 1
}

variable "ebs_volume_type" {
    default = "gp2"
}

variable "ebs_volume_size" {
    default = 20
}

variable "iam_role" {
    description = "The IAM role your EC2 will use to connect to other services"
}

variable "instance_type" {
    default = "t2.micro"
}

variable "listeners" {
    description = "Ingress port configurations for load balancer"
}

variable "security_groups" {
    description = "Security group(s) specific to this architecture and/or application"
}

variable "user_data" {
    description = "userData section which gets run on each EC2 @ instantiation -- throw your app-specific install/run code here"
}
