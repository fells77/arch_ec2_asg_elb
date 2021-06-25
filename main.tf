/*
These are the required fields needed to leverage this module:

    app_name                = var.app_name                      # Your app name; use [a-zA-Z_-] for best results
    aws_region              = var.aws_region                    # THe region you're deploying to
    ami_id                  = var.ami_id                        # The ID of the AMI you're using
    deploy_env              = var.deploy_env                    # The environment (dev/qa/prod) you're deploying to
    asg_max_size            = var.asg_max_size                  # Max number of instances in your autoscaling group
    asg_min_size            = var.asg_min_size                  # Min number of instances in your autoscaling group
    asg_desired_size        = var.asg_desired_size              # The desired (BAU) number of instances in your autoscaling group
    instance_type           = var.instance_type                 # The AWS instance type (such a "t2.micro") for your instances
    volume_type             = var.ebs_volume_type               # The type of disk your EC2 will use, suggest "gp2"
    volume_size             = var.ebs_volume_size               # The size (in GB) of your EC2 disk space
    s3_bucket_name          = var.s3_bucket_name                # You need a pre-existing S3 bucket for statefiles
    tag_owner_contact       = var.tag_owner_contact             # Email/identifier of group supporting the application
    tag_deployment_owner    = var.tag_deployment_owner          # Email/identifier of the person deploying this asset
    security_groups         = var.security_groups               # These should be created/exported from your app onfiguration

These must be defined in your app-level configuration
*/

terraform {
  required_providers {
    aws = "~> 3.37"
  }
}

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
        key                 = "DeploymentOwner"
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
