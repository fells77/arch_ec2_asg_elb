terraform {
  required_providers {
    aws = "~> 3.37"
  }
}

/*
module "app_build_data" {
app_name                = var.app_name
aws_region              = var.aws_region
ami_id                  = var.ami_id
deploy_env              = var.deploy_env
asg_max_size            = var.asg_max_size
asg_min_size            = var.asg_min_size
asg_desired_size        = var.asg_desired_size
instance_type           = var.instance_type
volume_type             = var.ebs_volume_type
volume_size             = var.ebs_volume_size
sf_bucket               = var.sf_bucket
s3_bucket_name          = var.s3_bucket_name
tag_owner_contact       = var.tag_owner_contact
tag_deployment_owner    = var.tag_deployment_owner
security_groups         = ""
}
*/

resource "aws_launch_configuration" "im_mr_meeseeks_look_at_me" {
    ebs_block_device {
        device_name = "/dev/xvda"
        volume_type = var.ebs_volume_type
        volume_size = var.ebs_volume_size
        encrypted   = true
    }
    iam_instance_profile        = var.iam_role
    image_id                    = var.ami_id[var.deploy_env]
    instance_type               = var.instance_type
    lifecycle {
        create_before_destroy = true
    }
    name                        = "${var.app_name}-cattle (or plants if you're vegetarian)"
    security_groups = split(
    ",",
    var.security_groups[format("%s.%s", lower(var.app_env), lower(var.aws_region))],
    )
    user_data = []
}

resource "aws_autoscaling_group" "meeseeks_box" {
    health_check_grace_period = 180
    health_check_type         = "EC2"
    launch_configuration      = var.aws_launch_configuration.im_mr_meeseeks_look_at_me.name
    load_balancers            = var.aws-elb.green_portal.name
    max_size                  = var.asg_max_size
    min_size                  = var.asg_min_size
    name                      = "${var.app_name}-asg"
    tag {
        key                 = "OwnerContact"
        value               = var.tag_owner_contact
        propagate_at_launch = true
    }
    tag {
        key                 = "deployment_owner"
        value               = var.tag_deployment_owner
        propagate_at_launch = true
    }
    depends_on = [aws_elb.green_portal]
}

resource "aws_elb" "green_portal" {
    access_logs {
        bucket        = var.sf_bucket
        interval      = 60
    }
    connection_draining         = true
    connection_draining_timeout = 400
    health_check {
        healthy_threshold   = 10
        unhealthy_threshold = 2
        timeout             = 5
        target              = "HTTP:3000/"
        interval            = 30
    }
    internal = true
    listener = [ var.listeners ]
    /*
    listener {
        instance_port     = 3000
        instance_protocol = "http"
        lb_port           = 3000
        lb_protocol       = "http"
    }
    */
    name    = "${var.app_name}-elb"
    subnets = []
    tags = {
        deployment_owner     = var.tag_deployment_owner
        OwnerContact        = var.tag_owner_contact
    }
}
