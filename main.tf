terraform {
    required_providers {
        aws = "~> 5"
    }
}

provider "aws" {
    region = var.aws_region
}

resource "aws_launch_template" "im_mr_meeseeks_look_at_me" {
    name                            = "${var.app_name}-launch_template"
    block_device_mappings {
        device_name                     = "/dev/sdf"
        ebs {
            volume_size = var.ebs_volume_size
            encrypted   = true
        }
    }
    ebs_optimized                   = true
    image_id                        = var.ami_id
    instance_type                   = var.instance_type
    metadata_options {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
        instance_metadata_tags      = "enabled"
    }
    monitoring {
        enabled                     = true
    }
    network_interfaces {
        associate_public_ip_address = true
    }
    vpc_security_group_ids          = [ aws_security_group.ec2_sg.id ]
    tag_specifications {
        resource_type               = "instance"
        tags = {
            Name = "test"
        }
    }
    user_data = filebase64(var.user_data)
}

resource "aws_autoscaling_group" "meeseeks_box" {
    health_check_grace_period = 180
    health_check_type         = "EC2"
    launch_template {
        id      = aws_launch_template.im_mr_meeseeks_look_at_me.id
        version = "$Latest"
    }
    load_balancers            = [ aws_elb.green_portal.name ]
    max_size                  = var.asg_max_size
    min_size                  = var.asg_min_size
    name                      = "${var.app_name}-asg"
    vpc_zone_identifier       = [ var.subnets ]
    tag {
        key                 = "Name"
        value               = "${var.app_name}-cattle (or plants if you're vegetarian)"
        propagate_at_launch = true
    }
    tag {
        key                 = "Application"
        value               = var.app_name
        propagate_at_launch = true
    }
    tag {
        key                 = "OwnerContact"
        value               = var.owner_contact
        propagate_at_launch = true
    }
    tag {
        key                 = "DeploymentOwner"
        value               = var.deployment_owner
        propagate_at_launch = true
    }
    depends_on = [ aws_elb.green_portal ]
}

resource "aws_elb" "green_portal" {
    /* User bucket needs to be properly configured first
    access_logs {
        bucket        = var.s3_bucket_name
        interval      = 60
    }
    */
    connection_draining         = true
    connection_draining_timeout = 300
    cross_zone_load_balancing   = true
    health_check {
        healthy_threshold   = var.hc_healthy_threshold
        unhealthy_threshold = var.hc_unhealthy_threshold
        timeout             = var.hc_timeout
        target              = var.hc_target
        interval            = var.hc_interval
    }
    internal                = false
    listener {
        instance_port     = var.listener_port
        instance_protocol = var.listener_protocol
        lb_port           = var.listener_port
        lb_protocol       = var.listener_protocol
    }
    name                    = "${var.app_name}-elb"
    security_groups         = [ aws_security_group.elb_sg.id ]
    subnets                 = [ var.subnets ]
    tags = {
        Application         = var.app_name
        DeploymentOwner     = var.deployment_owner
        OwnerContact        = var.owner_contact
    }
}

resource "aws_security_group" "elb_sg" {
    name        = "${var.app_name}-ELB security group"
    description = "Inbound traffic to ELB"
    vpc_id      = var.vpc_id
    ingress {
        description      = "Inbound from ELB"
        from_port        = var.app_port
        to_port          = var.app_port
        protocol         = "tcp"
        cidr_blocks      = [ "0.0.0.0/0" ]
    }
    ingress {
        description      = "garbage test ingress"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = [ "0.0.0.0/0" ]
    }
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = [ "0.0.0.0/0" ]
    }
    tags = {
        Application         = var.app_name
        DeploymentOwner     = var.deployment_owner
        OwnerContact        = var.owner_contact
    }
}

resource "aws_security_group" "ec2_sg" {
    name        = "${var.app_name}-EC2 security group"
    description = "Inbound traffic to EC2 from ELB"
    vpc_id      = var.vpc_id
    ingress {
        description      = "Inbound from ELB"
        from_port        = var.app_port
        to_port          = var.app_port
        protocol         = "tcp"
        security_groups  = [ aws_security_group.elb_sg.id ]
    }
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = [ "0.0.0.0/0" ]
    }
    tags = {
        Application         = var.app_name
        DeploymentOwner     = var.deployment_owner
        OwnerContact        = var.owner_contact
    }
}
