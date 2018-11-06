resource "aws_flow_log" "vpc_to_s3" {
  log_destination      = "${aws_s3_bucket.example.arn}"
  log_destination_type = "s3"
  traffic_type         = "${var.traffic_type}"
  vpc_id               = "${var.vpc_id}"
}

resource "aws_s3_bucket" "example" {
  bucket = "${var.bucket_name}"
}
