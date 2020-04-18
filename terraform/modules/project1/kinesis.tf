###
# Author : bsh0817
# Created : 2020 04 16
# Updated : 2020 04 16
###

resource "aws_kinesis_stream" "kinesis_stream" {
  name             = var.kinesis_stream_name
  shard_count      = 1
  tags             = var.tag_default
}

resource "aws_iam_role" "iam_for_kinesis_firehose" {
  name               = "${var.project_name}_iam_for_kinesis_firehose"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "iam_for_kinesis_firehose_policy" {
  name = "${var.project_name}_iam_for_kinesis_firehose_policy"
  role = aws_iam_role.iam_for_kinesis_firehose.id

  policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "glue:GetTable",
                "glue:GetTableVersion",
                "glue:GetTableVersions"
            ],
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
            ],
            "Resource": [
                "${aws_s3_bucket.nginx_log.arn}",
                "${aws_s3_bucket.nginx_log.arn}/*"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction",
                "lambda:GetFunctionConfiguration"
            ],
            "Resource": "${aws_lambda_function.firehose_lambda.arn}:$LATEST"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:GetShardIterator",
                "kinesis:GetRecords",
                "kinesis:ListShards"
            ],
            "Resource": "${aws_kinesis_stream.kinesis_stream.arn}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
  EOF
}

resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name             = var.kinesis_firehose_name
  destination      = "extended_s3"
  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.kinesis_stream.arn
    role_arn           = aws_iam_role.iam_for_kinesis_firehose.arn
  }
  extended_s3_configuration {
    role_arn   = aws_iam_role.iam_for_kinesis_firehose.arn
    bucket_arn = aws_s3_bucket.nginx_log.arn
    prefix              = "${var.log_bucket_kinesis_origin_path}success/"
    error_output_prefix = "${var.log_bucket_kinesis_origin_path}error/"
    buffer_interval     = 60
    buffer_size         = 1
    processing_configuration {
      enabled  = "true"

      processors {
        type   = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.firehose_lambda.arn}:$LATEST"
        }
        parameters {
          parameter_name  = "BufferSizeInMBs"
          parameter_value = "1"
        }
        parameters {
          parameter_name  = "BufferIntervalInSeconds"
          parameter_value = "60"
        }
      }
    }
  }
}