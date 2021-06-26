terraform {
    required_providers {
        aws = "~> 3.37"
        region = var.aws_region
    }
}

resource "aws_launch_configuration" "im_mr_meeseeks_look_at_me" {
    ebs_block_device {
        device_name = "/dev/xvda"
        volume_type = var.ebs_volume_type
        volume_size = var.ebs_volume_size
        encrypted   = true
    }
    #iam_instance_profile        = var.iam_role
    image_id                    = var.ami_id[var.app_env]
    instance_type               = var.instance_type
    lifecycle {
        create_before_destroy = true
    }
    name                        = "${var.app_name}-launch_configuration"
    security_groups             = [ aws_security_group.ec2_sg.id ]
    user_data                   = var.user_data
}

resource "aws_autoscaling_group" "meeseeks_box" {
    health_check_grace_period = 180
    health_check_type         = "EC2"
    launch_configuration      = aws_launch_configuration.im_mr_meeseeks_look_at_me.name
    load_balancers            = aws_elb.green_portal.name
    max_size                  = var.asg_max_size
    min_size                  = var.asg_min_size
    name                      = "${var.app_name}-asg"
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
    access_logs {
        bucket        = var.s3_bucket_name
        interval      = 60
    }
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
    internal                = true
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
