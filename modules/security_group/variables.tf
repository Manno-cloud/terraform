variable "vpc_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}



variable "security_groups" {
  description = "複数のセキュリティグループをまとめて作る"
  type = map(object({
    description = string
    ingress = object({
      rules = list(object({
        from_port   = optional(number)
        to_port     = optional(number)
        protocol    = optional(string)
        cidr_blocks = optional(list(string))
        source_sg   = optional(string)
      }))
    })
    egress = object({
      rules = list(object({
        from_port   = optional(number)
        to_port     = optional(number)
        protocol    = optional(string)
        cidr_blocks = optional(list(string))
        source_sg   = optional(string)
      }))
    })
  }))
}