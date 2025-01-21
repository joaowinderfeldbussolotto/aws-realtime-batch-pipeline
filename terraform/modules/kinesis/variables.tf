variable "stream_name" {
  description = "Name of the Kinesis stream"
  type        = string
}

variable "shard_count" {
  description = "Number of shards for the Kinesis stream"
  type        = number
  default     = 1
}

variable "retention_period" {
  description = "Data retention period in hours"
  type        = number
  default     = 24
}

variable "tags" {
  description = "Tags to apply to the Kinesis stream"
  type        = map(string)
  default     = {}
}
