variable "glue_job_role_name" {
  description = "Name for the Glue Job IAM role"
  type        = string
}

variable "job_name" {
  description = "Name of the Glue ETL job"
  type        = string
}

variable "timeout" {
  description = "Timeout for the Glue job in minutes"
  type        = number
  default     = 120
}



variable "raw_database_name" {
  description = "Name of the raw database"
  type        = string
}

variable "gold_database_name" {
  description = "Name of the gold database"
  type        = string
}

variable "raw_crawler_name" {
  description = "Name of the raw data crawler"
  type        = string
}

variable "gold_crawler_name" {
  description = "Name of the gold data crawler"
  type        = string
}

variable "raw_data_path" {
  description = "S3 path for raw data"
  type        = string
}

variable "gold_data_path" {
  description = "S3 path for gold data"
  type        = string
}


variable "local_script_path" {
  description = "Local path to the Glue ETL script"
  type        = string
}

variable "scripts_bucket_name" {
  description = "Name of the S3 bucket where Glue scripts will be stored"
  type        = string
}