output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lb_log_forwarder.lambda_function_arn
}

output "lambda_log_group_name" {
  description = "Name of the Lambda CloudWatch log group"
  value       = module.lb_log_forwarder.lambda_log_group_name
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group where ALB logs are forwarded"
  value       = aws_cloudwatch_log_group.alb_logs.name
}
