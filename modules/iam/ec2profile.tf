############################################
# IAM Role for EC2
############################################
resource "aws_iam_role" "ec2_role" {
  name = "${var.project}-${var.env}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = var.project
    Env     = var.env
  }
}

############################################
# IAM Policy for EC2 (S3 + CW Logs + SSM)
############################################
resource "aws_iam_policy" "ec2_policy" {
  name        = "${var.project}-${var.env}-ec2-policy"
  description = "Allow EC2 to access S3, CloudWatch Logs, and SSM"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # S3
      {
        Effect   = "Allow"
        Action   = ["s3:*"]
        Resource = "*"
      },
      # CloudWatch Logs
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      # SSM (Session Manager)
      {
        Effect   = "Allow"
        Action   = [
          "ssm:*",
          "ssmmessages:*",
          "ec2messages:*"
        ]
        Resource = "*"
      }
    ]
  })
}

############################################
# Attach Policy to the Role
############################################
resource "aws_iam_role_policy_attachment" "ec2_role_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

############################################
# Instance Profile (EC2 にアタッチする用)
############################################
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project}-${var.env}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}