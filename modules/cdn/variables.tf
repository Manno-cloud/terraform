variable "project" {
  type        = string
  description = "Project name (for tagging)"
}

variable "env" {
  type        = string
  description = "Environment (dev/stg/prod)"
}

variable "domain_name" {
  type        = string
  description = "CloudFront custom domain (e.g. cdn.manno-cloud.com)"
}

variable "hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for manno-cloud.com"
}

variable "web_acl_arn" {
  type        = string
  description = "WAF Web ACL ARN for CloudFront"
}
