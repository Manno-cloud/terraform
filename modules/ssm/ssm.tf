resource "aws_ssm_parameter" "parameter" {
  name        = var.parameter_name
  type        = "SecureString"
  value       = var.parameter_value
  overwrite   = true

  tags = {
    Project = var.project
    Env     = var.env
  }
}
