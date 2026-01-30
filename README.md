# terraform-aws-lb-log-forwarder

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Terraform module to deploy [aws-lb-log-forwarder](https://github.com/jdwit/aws-lb-log-forwarder) - a Lambda function that forwards ALB/NLB access logs from S3 to various destinations.

## Supported Destinations

This module supports forwarding to CloudWatch Logs. See [aws-lb-log-forwarder](https://github.com/jdwit/aws-lb-log-forwarder) for all available destinations.

## Usage

```hcl
module "lb_log_forwarder" {
  source  = "jdwit/lb-log-forwarder/aws"
  version = "~> 1.0"

  # Used for AWS resource prefix (Lambda, IAM role, etc.)
  name           = "alb-log-forwarder"
  s3_bucket_name = "my-alb-logs-bucket"

  # Version of the Lambda binary to download from GitHub releases
  # See: https://github.com/jdwit/aws-lb-log-forwarder/releases
  release_version = "1.0.0"

  # Graviton (arm64) is default for better performance and lower cost
  # architecture = "x86_64"

  lb_type      = "alb"
  destinations = "cloudwatch"

  cloudwatch_log_group  = "/aws/alb/access-logs"
  cloudwatch_log_stream = "alb-logs"
}
```

### Using a custom Lambda build

```hcl
module "lb_log_forwarder" {
  source  = "jdwit/lb-log-forwarder/aws"
  version = "~> 1.0"

  name           = "alb-log-forwarder"
  s3_bucket_name = "my-alb-logs-bucket"

  # Path to custom build (skips GitHub release download)
  lambda_zip_path = "/path/to/bootstrap.zip"
  architecture    = "arm64"  # Must match the build architecture

  lb_type      = "alb"
  destinations = "cloudwatch"

  cloudwatch_log_group  = "/aws/alb/access-logs"
  cloudwatch_log_stream = "alb-logs"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| aws | >= 5.0 |
| null | >= 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name prefix for resources | `string` | n/a | yes |
| s3_bucket_name | Name of the S3 bucket containing LB logs | `string` | n/a | yes |
| destinations | Comma-separated list of destinations (cloudwatch, stdout) | `string` | n/a | yes |
| release_version | Version of aws-lb-log-forwarder to deploy | `string` | `null` | no |
| lambda_zip_path | Path to a custom Lambda zip file (bootstrap.zip) | `string` | `null` | no |
| lb_type | Load balancer type: alb or nlb | `string` | `"alb"` | no |
| fields | Comma-separated list of fields to include | `string` | `""` | no |
| s3_prefix | S3 key prefix filter for Lambda trigger | `string` | `"AWSLogs/"` | no |
| s3_suffix | S3 key suffix filter for Lambda trigger | `string` | `".log.gz"` | no |
| architecture | Lambda CPU architecture (x86_64 or arm64) | `string` | `"arm64"` | no |
| memory_size | Lambda memory size in MB | `number` | `256` | no |
| timeout | Lambda timeout in seconds | `number` | `300` | no |
| reserved_concurrent_executions | Reserved concurrent executions for Lambda (-1 for no limit) | `number` | `-1` | no |
| log_retention_days | CloudWatch log retention for Lambda execution logs | `number` | `14` | no |
| cloudwatch_log_group | CloudWatch log group name for output | `string` | `""` | no |
| cloudwatch_log_stream | CloudWatch log stream name for output | `string` | `""` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| lambda_function_name | Name of the Lambda function |
| lambda_function_arn | ARN of the Lambda function |
| lambda_role_arn | ARN of the Lambda IAM role |
| lambda_role_name | Name of the Lambda IAM role |
| lambda_log_group_name | Name of the Lambda CloudWatch log group |
| lambda_log_group_arn | ARN of the Lambda CloudWatch log group |

