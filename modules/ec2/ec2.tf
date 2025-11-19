resource "aws_instance" "ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile = var.iam_instance_profile

  user_data = var.user_data

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  tags = merge({
    Name = "${var.project}-${var.env}-ec2-${var.name}"
  }, var.tags)
}