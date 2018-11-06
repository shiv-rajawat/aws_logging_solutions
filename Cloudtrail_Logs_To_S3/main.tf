resource "aws_s3_bucket" "ct_logging_bucket" {
  bucket = "${var.bucket_name}"
}

resource "aws_s3_bucket_policy" "ct_logging_bucket" {
  bucket = "${aws_s3_bucket.ct_logging_bucket.id}"
  policy = <<POLICY
{
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "AWSCloudTrailAclCheck20150319",
              "Effect": "Allow",
              "Principal": {
                  "Service": "cloudtrail.amazonaws.com"
              },
              "Action": "s3:GetBucketAcl",
              "Resource": "arn:aws:s3:::${var.bucket_name}"
          },
          {
              "Sid": "AWSCloudTrailWrite20150319",
              "Effect": "Allow",
              "Principal": {
                  "Service": "cloudtrail.amazonaws.com"
              },
              "Action": "s3:PutObject",
              "Resource": "arn:aws:s3:::${var.bucket_name}/*",
              "Condition": {
                  "StringEquals": {
                      "s3:x-amz-acl": "bucket-owner-full-control"
                  }
              }
          }
      ]
  }
POLICY
}

resource "aws_cloudtrail" "foobar" {
  name                          = "${var.trail_name}"
  s3_bucket_name                = "${aws_s3_bucket.ct_logging_bucket.id}"
  s3_key_prefix                 = "${var.bucket_prefix}"
  include_global_service_events = true

  event_selector {
    read_write_type = "All"
    include_management_events = true

  data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda"]
    }

  data_resource {
        type   = "AWS::S3::Object"
        values = ["arn:aws:s3:::"]
    }
  }
}
