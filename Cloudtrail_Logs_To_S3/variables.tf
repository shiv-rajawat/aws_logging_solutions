variable "aws_region" {
  type = "string"
  default = "us-east-2"
}

variable "bucket_name" {
  type = "string"
  default = "shiv-g-cloudtrail-logging-bucket"
}

variable "bucket_prefix" {
  type = "string"
  default = "random"
}

variable "trail_name" {
  type = "string"
  default = "the-holy-trail"
}

variable "account_id" {
    type = "string"
    default = "737765950268"
}
