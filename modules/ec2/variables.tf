variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "name" {
  description = "EC2の役割名"
  type        = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "iam_instance_profile" {
  type    = string
  default = null
}

variable "volume_size" {
  type    = number
  default = 8
}

variable "user_data" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}