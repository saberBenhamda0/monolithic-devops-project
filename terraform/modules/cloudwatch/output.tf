output "aws_cloudwatch_waf_logs_arn" {
  value = aws_cloudwatch_log_group.waf_logs.arn
}