resource "aws_launch_template" "lt" {
  name_prefix   = "${var.project}-${var.env}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = var.security_group_ids

    iam_instance_profile {
    name = var.iam_instance_profile_name
  }


  user_data = base64encode(var.user_data)

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project}-${var.env}-ec2"
    }
  }
}