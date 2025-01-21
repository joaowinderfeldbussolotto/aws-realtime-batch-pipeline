variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "enable_versioning" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Allow terraform to destroy bucket with contents"
  type        = bool
  default     = true
}
