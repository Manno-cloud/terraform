resource "aws_wafv2_web_acl" "waf" {
  name        = "${var.project}-${var.env}-waf"
  description = "WAF for CloudFront"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  ###############################################
  # Managed Rule Set: CommonRuleSet
  ###############################################
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 0

    action {
      allow {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  ###############################################
  # Managed Rule Set: AmazonIpReputationList
  ###############################################
  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 1

    action {
      allow {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IPReputation"
      sampled_requests_enabled   = true
    }
  }

  ###############################################
  # Managed Rule Set: KnownBadInputsRuleSet
  ###############################################
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    action {
      allow {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "KnownBadInputs"
      sampled_requests_enabled   = true
    }
  }

  ###############################################
  # Managed Rule Set: SQLiRuleSet
  ###############################################
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 3

    action {
      allow {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLi"
      sampled_requests_enabled   = true
    }
  }

  ###############################################
  # Web ACL 全体の visibility_config
  ###############################################
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WAF"
    sampled_requests_enabled   = true
  }
}

###############################################
# CloudFront Distribution と紐付け
###############################################
resource "aws_wafv2_web_acl_association" "cf_assoc" {
  resource_arn = var.cloudfront_distribution_arn
  web_acl_arn  = aws_wafv2_web_acl.waf.arn
}
