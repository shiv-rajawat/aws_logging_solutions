variable "aws_region" {
  type = "string"
}

variable "bucket_name" {
  type = "string"
}

variable "subnet_id" {
  type = "string"
}

variable "traffic_type" {
  ## supported types are ACCEPT/REJECT/ALL
  type = "string"
}

