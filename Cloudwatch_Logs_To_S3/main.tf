resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
EOF
}


resource "aws_iam_role_policy" "lambda_execution_policy" {
  name = "lambda_execution_policy"
  role = "${aws_iam_role.lambda_execution_role.id}"

  policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "VisualEditor0",
              "Effect": "Allow",
              "Action": [
                  "logs:CreateExportTask",
                  "logs:DescribeExportTasks",
                  "logs:CreateLogStream",
                  "logs:DescribeLogGroups",
                  "s3:PutBucketPolicy",
                  "s3:CreateBucket",
                  "s3:ListBucket",
                  "logs:CreateLogGroup",
                  "logs:PutLogEvents",
                  "s3:PutObject",
                  "s3:PutObjectAcl",
                  "s3:GetObject",
                  "s3:GetObjectAcl",
                  "s3:DeleteObject"
              ],
              "Resource": "*"
          }
      ]
}
EOF
}

resource "aws_s3_bucket" "logging_bucket" {
  bucket = "${var.bucket_name}"
}

resource "aws_s3_bucket_policy" "logging_bucket" {
  bucket = "${aws_s3_bucket.logging_bucket.id}"
  policy =<<POLICY
{
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Principal": {
                  "Service": "logs.us-east-2.amazonaws.com"
              },
              "Action": "s3:GetBucketAcl",
              "Resource": "arn:aws:s3:::${var.bucket_name}"
          },
          {
              "Effect": "Allow",
              "Principal": {
                  "Service": "logs.us-east-2.amazonaws.com"
              },
              "Action": "s3:PutObject",
              "Resource": "arn:aws:s3:::${var.bucket_name}/random/*",
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

resource "aws_lambda_function" "check_foo" {
    filename = "lambda_function_payload.zip"
    function_name = "${var.function_name}"
    role = "${aws_iam_role.lambda_execution_role.arn}"
    handler = "lambda_code.lambda_handler"
    runtime = "python3.6"
}

resource "aws_cloudwatch_event_rule" "every_five_minutes" {
    name = "every-five-minutes"
    description = "Fires every five minutes"
    schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "check_foo_every_five_minutes" {
    rule = "${aws_cloudwatch_event_rule.every_five_minutes.name}"
    target_id = "check_foo"
    arn = "${aws_lambda_function.check_foo.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.check_foo.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.every_five_minutes.arn}"
}
