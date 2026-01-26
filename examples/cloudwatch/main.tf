resource "aws_cloudwatch_log_group" "alb_logs" {
  name              = "/aws/alb/access-logs"
  retention_in_days = 1
}

module "lb_log_forwarder" {
  source = "../../"

  name         = "alb-log-forwarder"
  architecture = var.architecture

  # Use release_version to download from GitHub releases,
  # or lambda_zip_path for custom builds
  release_version = var.release_version
  lambda_zip_path = var.lambda_zip_path

  s3_bucket_name = var.s3_bucket_name

  lb_type      = "alb"
  destinations = "cloudwatch"

  cloudwatch_log_group  = aws_cloudwatch_log_group.alb_logs.name
  cloudwatch_log_stream = "alb-logs"

  tags = {
    Environment = "test"
  }
}
