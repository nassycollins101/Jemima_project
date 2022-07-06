resource "aws_placement_group" "my_placement_grp" {
  name     = "jemima-pg"
  strategy = "cluster"
}

# data "aws_ami" "ubuntu" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"] # Canonical
# }

# resource "aws_launch_configuration" "as_configuration" {
#   name          = "web_config"
#   image_id      = data.aws_ami.ubuntu.id
#   instance_type = "t2.micro"
# }

# resource "aws_autoscaling_group" "Jemima_Asg" {
#   name                      = "Jemima-Asg"
#   max_size                  = 6
#   min_size                  = 2
#   health_check_grace_period = 300
#   health_check_type         = "ELB"
#   desired_capacity          = 3
#   force_delete              = true
#   placement_group           = aws_placement_group.my_placement_grp.id
#   launch_configuration      = aws_launch_configuration.as_configuration.name
#   vpc_zone_identifier       = [aws_subnet.collins_public_subnet1.id, aws_subnet.collins_public_subnet2.id]

#   initial_lifecycle_hook {
#     name                 = "foobar"
#     default_result       = "CONTINUE"
#     heartbeat_timeout    = 2000
#     lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

#     notification_metadata = <<EOF
# {
#   "foo": "bar"
# }
# EOF

#     notification_target_arn = "arn:aws:sqs:us-east-1:444455556666:queue1*"
#     role_arn                = "arn:aws:iam::123456789012:role/S3Access"
#   }

#   tag {
#     key                 = "foo"
#     value               = "bar"
#     propagate_at_launch = true
#   }

#   timeouts {
#     delete = "15m"
#   }

#   tag {
#     key                 = "lorem"
#     value               = "ipsum"
#     propagate_at_launch = false
#   }
# }

resource "aws_launch_template" "my_launch_template" {
  name = "jemima-LT"

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
    }
  }

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  cpu_options {
    core_count       = 4
    threads_per_core = 2
  }

  credit_specification {
    cpu_credits = "standard"
  }

  disable_api_stop        = true
  disable_api_termination = true

  ebs_optimized = true

  elastic_gpu_specifications {
    type = "test"
  }

  elastic_inference_accelerator {
    type = "eia1.medium"
  }

  iam_instance_profile {
    name = "test"
  }

  image_id = "ami-test"

  instance_initiated_shutdown_behavior = "terminate"

  instance_market_options {
    market_type = "spot"
  }

  instance_type = "t2.micro"

  kernel_id = "test"

  key_name = "test"

  license_specification {
    license_configuration_arn = "arn:aws:license-manager:eu-west-1:123456789012:license-configuration:lic-0123456789abcdef0123456789abcdef"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
  }

  placement {
    availability_zone = "us-west-2a"
  }

  ram_disk_id = "test"

  vpc_security_group_ids = ["sg-12345678"]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
    }
  }

  user_data = filebase64("${path.module}/example.sh")
}

resource "aws_autoscaling_group" "my_ASG" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  placement_group           = aws_placement_group.my_placement_grp.id
  vpc_zone_identifier       = [aws_subnet.collins_public_subnet1.id, aws_subnet.collins_public_subnet2.id]

  initial_lifecycle_hook {
    name                 = "foobar"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 2000
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = "$Latest"
    }
  }
}

# Create a new load balancer attachment
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.my_ASG.id
  elb                    = aws_elb.my_elb.id
}