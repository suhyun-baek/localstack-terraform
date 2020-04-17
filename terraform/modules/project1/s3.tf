###
# Author : bsh0817
# Created : 2020 04 16
# Updated : 2020 04 16
###

resource "aws_s3_bucket" "nginx_log" {
        bucket = var.log_bucket_name
        acl    = "private"
        tags = var.tag_default
        lifecycle {
                prevent_destroy = false
        }
}