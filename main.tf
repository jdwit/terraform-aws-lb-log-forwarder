locals {
  use_local_zip = var.lambda_zip_path != null

  arch_suffix   = var.architecture == "arm64" ? "arm64" : "amd64"
  download_url  = local.use_local_zip ? null : "https://github.com/jdwit/aws-lb-log-forwarder/releases/download/v${var.release_version}/aws-lb-log-forwarder_linux_${local.arch_suffix}.zip"
  zip_path      = local.use_local_zip ? var.lambda_zip_path : "${path.module}/.terraform/aws-lb-log-forwarder_${var.release_version}_${local.arch_suffix}.zip"
  s3_bucket_arn = "arn:aws:s3:::${var.s3_bucket_name}"

  environment_variables = merge(
    {
      LB_TYPE      = var.lb_type
      DESTINATIONS = var.destinations
    },
    var.fields != "" ? { FIELDS = var.fields } : {},

    # CloudWatch output
    var.cloudwatch_log_group != "" ? {
      CLOUDWATCH_LOG_GROUP  = var.cloudwatch_log_group
      CLOUDWATCH_LOG_STREAM = var.cloudwatch_log_stream
    } : {},
  )
}

check "version_or_zip_required" {
  assert {
    condition     = var.lambda_zip_path != null || var.release_version != null
    error_message = "Either lambda_zip_path or release_version must be set"
  }
}

resource "null_resource" "download_lambda_zip" {
  count = local.use_local_zip ? 0 : 1

  triggers = {
    version = var.release_version
    arch    = var.architecture
  }

  provisioner "local-exec" {
    command = "mkdir -p $(dirname ${local.zip_path}) && curl -fsSL -o ${local.zip_path} ${local.download_url}"
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_lambda_function" "this" {
  function_name = var.name
  role          = aws_iam_role.lambda.arn
  handler       = "bootstrap"
  runtime       = "provided.al2023"
  architectures = [var.architecture]

  filename         = local.zip_path
  source_code_hash = fileexists(local.zip_path) ? filebase64sha256(local.zip_path) : null

  memory_size = var.memory_size
  timeout     = var.timeout

  reserved_concurrent_executions = var.reserved_concurrent_executions

  environment {
    variables = local.environment_variables
  }

  tags = var.tags

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    null_resource.download_lambda_zip,
  ]
}

resource "aws_lambda_permission" "s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = local.s3_bucket_arn
}

resource "aws_s3_bucket_notification" "this" {
  bucket = var.s3_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.this.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.s3_prefix
    filter_suffix       = var.s3_suffix
  }

  depends_on = [aws_lambda_permission.s3]
}
