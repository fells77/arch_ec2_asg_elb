# arch_ec2_asg_elb
OpenTofu (replaces Terraform) module for EC2/ASG/ELB architecture


## Required fields
|Variable name|Description|
|-------------|-----------|
|var.app_name                      |# Your app name; use [a-zA-Z0-9_-] for best results|
|var.aws_region                    |# The region you're deploying to|
|var.ami_id                        |# The ID of the AMI you're using|
|var.deploy_env                    |# The environment (dev/qa/prod) you're deploying to|
|var.asg_max_size                  |# Max number of instances in your autoscaling group|
|var.asg_min_size                  |# Min number of instances in your autoscaling group|
|var.asg_desired_size              |# The desired (BAU) number of instances in your autoscaling group|
|var.instance_type                 |# The AWS instance type (such a "t2.micro") for your instances|
|var.ebs_volume_type               |# The type of disk your EC2 will use, suggest "gp2"|
|var.ebs_volume_size               |# The size (in GB) of your EC2 disk space (int type -- no quotes)|
|var.s3_bucket_name                |# You need a pre-existing S3 bucket for statefiles|
|var.tag_owner_contact             |# Email/identifier of group supporting the application|
|var.tag_deployment_owner          |# Email/identifier of the person deploying this asset|
|var.security_groups               |# These should be created/exported from your app configuration|
