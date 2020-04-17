###
# Author : bsh0817
# Created : 2020 04 16
# Updated : 2020 04 16
###

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_firehose_lambda"
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


resource "aws_iam_role_policy" "iam_for_lambda_policy" {
  name = "iam_for_lambda_policy"
  role = aws_iam_role.iam_for_lambda.id

  policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "logs:CreateLogStream",
                "s3:ListBucket",
                "s3:DeleteObject",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "*",
                "arn:aws:s3:::${var.log_bucket_name}",
                "arn:aws:s3:::${var.log_bucket_name}/*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "*"
        }
    ]
}
  EOF
}

data "archive_file" "zip" {
  type        = "zip"
  source_file = "./hello_lambda.py"
  output_path = "hello_lambda.zip"
}


resource "aws_lambda_function" "firehose_lambda" {
  function_name = "firehose_lambda"

  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256

  role    = aws_iam_role.iam_for_lambda.arn
  handler = "hello_lambda.lambda_handler"
  runtime = "python3.7"
  tags = var.tag_default
  environment {
    variables = {
      greeting = "Hello"
      log_bucket_name = "${var.log_bucket_name}"
      log_bucket_base_path = "${var.log_bucket_base_path}"
    }
  }
}