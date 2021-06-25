variable "app_name" {
    default = ""
}

variable "aws_region" {
    default = ""
}

variable "ami_id" {
    default = ""
}

variable "deploy_env" {
    default = ""
}

variable "asg_max_size" {
    default = 1
}

variable "asg_min_size" {
    default = 1
}

variable "asg_desired_size" {
    default = 1
}

variable "instance_type" {
    default = "t2.micro"
}

variable "ebs_volume_type" {
    default = "gp2"
}

variable "ebs_volume_size" {
    default = 20
}

variable "s3_bucket_name" {
    default = ""
}

variable "tag_owner_contact" {
    defaut = ""
}

variable "tag_deployment_owner" {
    default = ""
}
