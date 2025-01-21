# modules/kinesis/main.tf
resource "aws_kinesis_stream" "stream" {
  name             = var.stream_name
  retention_period = var.retention_period

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  tags = var.tags
}

