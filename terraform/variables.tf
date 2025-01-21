variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "latitude" {
  description = "Latitude for weather data"
  type        = string
}

variable "longitude" {
  description = "Longitude for weather data"
  type        = string
}

variable "tomorrow_api_key" {
  description = "Tomorrow.io API key"
  type        = string
  sensitive   = true
}

variable "precipitation_probability" {
  description = "Threshold for precipitation probability"
  type        = number
}

variable "rain_intensity" {
  description = "Threshold for rain intensity"
  type        = number
}

variable "wind_gust" {
  description = "Threshold for wind gust"
  type        = number
}

variable "wind_speed" {
  description = "Threshold for wind speed"
  type        = number
}

variable "kinesis_stream_name" {
  description = "Name of the Kinesis stream"
  type        = string
}

variable "kinesis_shard_count" {
  description = "Number of shards for Kinesis stream"
  type        = number
  default     = 1
}

variable "sns_topic_name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "notification_email" {
  description = "Email address for SNS notifications"
  type        = string
}