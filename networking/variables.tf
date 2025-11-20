variable "domain_name" {
  description = "ACM 証明書を発行するドメイン名"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 Hosted Zone ID"
  type        = string
}

variable "project" {
  description = "Project name used for tagging"
  type        = string
}

variable "env" {
  description = "Environment name (dev/stg/prod)"
  type        = string
}