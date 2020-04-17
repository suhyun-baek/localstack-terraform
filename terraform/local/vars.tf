variable "project_name" {
    default = "nginx-log.bsh0817"
    description = "project name"

}

variable "log_bucket_base_path" {
    default = "nginx/kinesis/firehose/migration/day="
    description = "log bucket base path"
}

variable "log_bucket_kinesis_origin_path" {
    default = "nginx/kinesis/firehose/origin/"
    description = "log bucket kinesis origin path"
}


locals {
    tag_default = {
        "project"    = "${var.project_name}"
        "Author"     = "bsh0817"
        "Created-at" = "2020-04-16"
    }
}
