module "project1" {
  source                             = ".././modules/project1"
  log_bucket_name                    = var.project_name
  log_bucket_kinesis_origin_path     = var.log_bucket_kinesis_origin_path
  log_bucket_base_path               = var.log_bucket_base_path
  kinesis_stream_name                = "${var.project_name}-stream"
  kinesis_firehose_name              = "${var.project_name}-firehose"
  tag_default                        = local.tag_default
}

