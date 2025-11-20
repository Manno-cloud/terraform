variable "project" { type = string }
variable "env"     { type = string }

variable "db_name" {
  type    = string
  default = "testdb"
}

variable "username" {
  type    = string
  default = "admin"
}

variable "password" {
  type      = string
  sensitive = true
}

variable "subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "RDS security group IDs"
  type        = list(string)
}

variable "storage_gb" {
  type    = number
  default = 20
}