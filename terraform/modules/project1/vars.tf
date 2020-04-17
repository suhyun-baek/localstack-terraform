variable "log_bucket_name" {
    description = "bucket name"
}

variable "tag_default" {
	type 	= map(string)
    description = "default tag"
	default = {
		"Author"     = "bsh0817"
        "Created-at" = "2020-04-16"
	}
}

variable "kinesis_stream_name" {
    default = "nginx-log-stream"
    description = "kinesis stream name"
}

variable "kinesis_firehose_name" {
    default = "nginx-log-firehose"
    description = "kinesis stream name"
}

variable "log_bucket_base_path" {
    default = "nginx/kinesis/firehose/migration/day="
    description = "log bucket base path"
}

variable "log_bucket_kinesis_origin_path" {
    default = "nginx/kinesis/firehose/origin/"
    description = "log bucket kinesis origin path"
}

