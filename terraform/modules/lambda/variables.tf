variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "source_path" {
  description = "Local path to Lambda function code"
  type        = string
  default     = null
}

variable "handler" {
  description = "Lambda function handler"
  type        = string
}

variable "runtime" {
  description = "Lambda function runtime"
  type        = string
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128
}

variable "environment_variables" {
  description = "Environment variables for Lambda function"
  type        = map(string)
  default     = {}
}

variable "custom_role_arn" {
  description = "ARN of custom IAM role to use for the Lambda function"
  type        = string
  default     = null
}

variable "managed_policy_arns" {
  description = "List of managed IAM policy ARNs to attach to the Lambda role"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}

variable "custom_policy_json" {
  description = "Custom IAM policy JSON to attach to the Lambda role"
  type        = string
  default     = null
}

variable "triggers" {
  description = "Map of trigger configurations"
  type = map(object({
    statement_id = string
    principal    = string
    source_arn   = string
  }))
  default = {}
}

variable "kinesis_trigger" {
  description = "Configuration for Kinesis trigger"
  type = object({
    source_arn = string
  })
  default = null
}