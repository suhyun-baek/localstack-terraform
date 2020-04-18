variable "project_name" {
    description = "project name"
}

variable "log_bucket_name" {
    description = "bucket name"
}

variable "tag_default" {
    type        = map(string)
    description = "default tag"
}

variable "kinesis_stream_name" {
    description = "kinesis stream name"
}

variable "kinesis_firehose_name" {
    description = "kinesis stream name"
}

variable "log_bucket_base_path" {
    description = "log bucket base path"
}

variable "log_bucket_kinesis_origin_path" {
    description = "log bucket kinesis origin path"
}

