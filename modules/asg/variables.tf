variable "project" { type = string }
variable "env" { type = string }

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "user_data" {
  type    = string
  default = ""
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3
}

variable "target_group_arn" {
  type = string
}

variable "iam_instance_profile_name" {
  type        = string
  description = "IAM instance profile name"
}