variable "name" {
  description = "Name prefix for ALB"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnets" {
  description = "Public subnets for ALB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "ALB security groups"
  type        = list(string)
}

variable "target_type" {
  type        = string
  description = "Target type for ALB target group (instance or ip)"
}

variable "target_port" {
  description = "Port for target group"
  type        = number
  default     = 80
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN for HTTPS listener"
  default     = null
}

variable "enable_https" {
  type        = bool
  description = "Whether to enable HTTPS listener"
  default     = false
}
