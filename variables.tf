variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket containing LB logs"
  type        = string
}

variable "lb_type" {
  description = "Load balancer type: alb or nlb"
  type        = string
  default     = "alb"

  validation {
    condition     = contains(["alb", "nlb"], var.lb_type)
    error_message = "lb_type must be 'alb' or 'nlb'"
  }
}

variable "destinations" {
  description = "Comma-separated list of destinations (cloudwatch, stdout)"
  type        = string

  validation {
    condition = alltrue([
      for d in split(",", var.destinations) : contains(["cloudwatch", "stdout"], trimspace(d))
    ])
    error_message = "destinations must be: cloudwatch, stdout"
  }
}

variable "fields" {
  description = "Comma-separated list of fields to include (default: all)"
  type        = string
  default     = ""
}

variable "s3_prefix" {
  description = "S3 key prefix filter for Lambda trigger"
  type        = string
  default     = "AWSLogs/"
}

variable "s3_suffix" {
  description = "S3 key suffix filter for Lambda trigger"
  type        = string
  default     = ".log.gz"
}

variable "release_version" {
  description = "Version of aws-lb-log-forwarder to deploy (e.g., '1.0.0'). See https://github.com/jdwit/aws-lb-log-forwarder/releases. Ignored if lambda_zip_path is set."
  type        = string
  default     = null
}

variable "lambda_zip_path" {
  description = "Path to a custom Lambda zip file (bootstrap.zip). When set, skips downloading from GitHub releases."
  type        = string
  default     = null
}

variable "architecture" {
  description = "Lambda CPU architecture (x86_64 or arm64)"
  type        = string
  default     = "arm64"

  validation {
    condition     = contains(["x86_64", "arm64"], var.architecture)
    error_message = "architecture must be 'x86_64' or 'arm64'"
  }
}

variable "memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 256
}

variable "timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 300
}

variable "reserved_concurrent_executions" {
  description = "Reserved concurrent executions for Lambda (-1 for no limit)"
  type        = number
  default     = -1
}

variable "log_retention_days" {
  description = "CloudWatch log retention for Lambda execution logs"
  type        = number
  default     = 14
}

# CloudWatch output configuration
variable "cloudwatch_log_group" {
  description = "CloudWatch log group name for output"
  type        = string
  default     = ""
}

variable "cloudwatch_log_stream" {
  description = "CloudWatch log stream name for output"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
