variable "topic_name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "email_subscribers" {
  description = "List of email addresses to subscribe to the topic"
  type        = list(string)
  default     = []
}