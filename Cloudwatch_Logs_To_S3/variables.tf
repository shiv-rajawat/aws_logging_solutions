variable "aws_region" {
  type = "string"
  default = "us-east-2"
}

variable "function_name" {
  type = "string"
  default = "my_lambda_function"
}

variable "bucket_name" {
  type = "string"
  default = "shiv-g-cw-logging-bucket"
}
