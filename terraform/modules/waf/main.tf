resource "aws_wafv2_web_acl" "infra_waf" {

  name        = "main_infra_WAF"
  description = "main infra WAF"
  scope       = "REGIONAL" # this WAF is only applied to regional ressources

  # the default rule like if any request doesn't match any of the below rules it gonna be allowed 
  # if we wanted it to be blocked we will do block {}.

  default_action {
    allow {}
  }

  rule {
    name     = "rule-1"
    priority = 1 # rules are order by priority lowest numbers first.

    # this is used in managed rules like we override the action instead of actually blocking the requrst
    # we "count" mean we log it for testing purposes.
    override_action {
      count {}
    }

    statement {

      managed_rule_group_statement {
        # manaaged rules name and vendor
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        # action of the sub-managed-rules in this case it just log and not block 
        rule_action_override {

            # this log request with very long query string 
          name = "SizeRestrictions_QUERYSTRING"

          action_to_use {
            count {}
          }

        }

        # action of the sub-managed-rules in this case it just log and not block 
        rule_action_override {
          action_to_use {
            count {}
          }

          name = "NoUserAgent_HEADER"
        }

        # those rules only applied to requestr comming from US or NL
        scope_down_statement {
          geo_match_statement {
            country_codes = ["US"]
          }
        }
      }

    }

    # we have this per rule
    # this first one enable the logs to be in cloudwatch
    # second one is the metric name
    # and last one save a sample of the requests if we want to troubleshoot or debug something.
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "friendly-rule-metric-name"
      sampled_requests_enabled   = false
    }
  }

# standard aws resources tags
  # tags = {
  #   Tag1 = "Value1"
  #   Tag2 = "Value2"
  # }

/*
Relevant to AWS WAF's CAPTCHA/Challenge and bot-control token features.
 It lists domains that are allowed to receive/embed the WAF integration token
*/
  token_domains = ["mywebsite.com", "myotherwebsite.com"]


  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  }
}

# the below is used to configure WAF to write logs to cloudwatch

# 2. Wire WAF to write into it
resource "aws_wafv2_web_acl_logging_configuration" "waf_logging" {

# the arn of WAF that going to write logs 
  resource_arn            = aws_wafv2_web_acl.infra_waf.arn
  # the destination arn
  log_destination_configs = [var.aws_cloudwatch_waf_logs_arn]


# this part remove the headers from logging when sending logs to LGTM.
  redacted_fields {
    single_header {
      name = "authorization"
    }
  }
}

# this used to attach the WAF to a aws internet gatewaay resource
resource "aws_wafv2_web_acl_association" "infra_waf_assoc" {
  resource_arn = var.aws_internet_gateway_id
  web_acl_arn  = aws_wafv2_web_acl.infra_waf.arn
}