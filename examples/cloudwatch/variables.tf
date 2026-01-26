variable "s3_bucket_name" {
  description = "Name of the S3 bucket containing LB logs"
  type        = string
}

variable "lambda_zip_path" {
  description = "Path to a custom Lambda zip file (bootstrap.zip)"
  type        = string
  default     = null
}

variable "release_version" {
  description = "Version to download from GitHub releases (for production)"
  type        = string
  default     = null
}

variable "architecture" {
  description = "Lambda CPU architecture (x86_64 or arm64)"
  type        = string
  default     = "arm64"
}
