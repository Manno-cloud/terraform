output "topic_arn" {
  description = "CloudWatch Alarm の通知先となる SNS トピック ARN"
  value       = aws_sns_topic.alert.arn
}