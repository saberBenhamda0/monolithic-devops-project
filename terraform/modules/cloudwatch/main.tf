

# resource "aws_cloudwatch_log_group" "app_logs" {
#   name              = "/aws/application/my-app"
#   retention_in_days = 30
# }


resource "aws_cloudwatch_log_resource_policy" "waf_logs_policy" {
  policy_name = "AWSWAFLogsPolicy"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSWAFLogsPermission"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.waf_logs.arn}:*"
      }
    ]
  })
}
# 1. Log group WAF will write into (name MUST start with aws-waf-logs-)
resource "aws_cloudwatch_log_group" "waf_logs" {
  name              = "aws-waf-logs-production"
  retention_in_days = 14
}

/*╬
You're just telling AWS: "Create this folder for logs, and automatically delete anything older than 30 days."
Without retention_in_days, logs are kept forever by default — which quietly racks up storage costs over time.
That's actually one of the most common reasons people define log groups explicitly in Terraform: 
to control retention and avoid surprise bills.

*/
// cloudwatch dashboard


# resource "aws_cloudwatch_dashboard" "main" {
#   dashboard_name = "app-overview"

#   dashboard_body = jsonencode({
#     widgets = [
#       {
#         type   = "metric"
#         x      = 0
#         y      = 0
#         width  = 12
#         height = 6
#         properties = {
#           metrics = [
#             ["AWS/EC2", "CPUUtilization", "InstanceId", aws_instance.example.id]
#           ]
#           period = 300
#           stat   = "Average"
#           region = "us-east-1"
#           title  = "EC2 CPU Utilization"
#         }
#       }
#     ]
#   })
# }


# resource "aws_cloudwatch_metric_alarm" "high_cpu" {

#   alarm_name          = "high-cpu-utilization"
#   alarm_description   = "Triggers when CPU exceeds 80% for 10 minutes"

# # that to do when alarm do the ALERT mode and what to do when it goes back to the NORMAL mode.
#   alarm_actions       = [aws_sns_topic.alerts.arn]
#   ok_actions          = [aws_sns_topic.alerts.arn]

  
  
# # the comparison logic.  
#   comparison_operator = "GreaterThanThreshold"

# # which metrics to track 
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"

# # we evaluate that on each 300 second and use the average we got in 300 second and we compare againt 
# # threshold which is it 80% percent.
#   period              = 300
#   statistic           = "Average"
#   threshold           = 80

# # how much times we need to bypass 80% for the alarm to get triggered. 
#   evaluation_periods  = 2


# /*
# dimensions — { InstanceId = aws_instance.example.id }
# Narrows the metric down to a specific resource. 
# CPUUtilization under AWS/EC2 exists for every EC2 instance in your 
# account — dimensions tell CloudWatch which one specifically to watch.
# Here, it's pointing at the EC2 instance created elsewhere in your Terraform config (aws_instance.example).
# */

#   dimensions = {
#     InstanceId = aws_instance.example.id
#   }
# }

# # it similaire to kafka here we create a topic and subscribe to it below and we use the email protocol nd an email endpoint.
# resource "aws_sns_topic" "alerts" {
#   name = "cloudwatch-alerts"
# }

# resource "aws_sns_topic_subscription" "email" {
#   topic_arn = aws_sns_topic.alerts.arn
#   protocol  = "email"
#   endpoint  = "you@example.com"
# }