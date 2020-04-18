variable "project_name" {
    default = "nginx-log.bsh0817"
    description = "project name"

}

locals {
    tag_default = {
        "project"    = "${var.project_name}"
        "Author"     = "bsh0817"
        "Created-at" = "2020-04-16"
    }
    log_bucket_kinesis_origin_path = "${var.project_name}/kinesis/firehose/origin/"
    log_bucket_base_path = "${var.project_name}/kinesis/firehose/migration/day="
}
