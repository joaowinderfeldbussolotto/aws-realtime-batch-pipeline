resource "aws_lambda_function" "function" {
  filename         = var.source_path != null ? data.archive_file.lambda_zip[0].output_path : null
  source_code_hash = var.source_path != null ? data.archive_file.lambda_zip[0].output_base64sha256 : null
  function_name    = var.function_name
  role            = var.custom_role_arn != null ? var.custom_role_arn : aws_iam_role.lambda_role[0].arn
  handler         = var.handler
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size

  environment {
    variables = var.environment_variables
  }
}

# Create ZIP file for Lambda function from local path
data "archive_file" "lambda_zip" {
  count       = var.source_path != null ? 1 : 0
  type        = "zip"
  source_dir  = var.source_path
  output_path = "${path.module}/files/${var.function_name}.zip"
}

# IAM role for Lambda (created only if custom_role_arn is not provided)
resource "aws_iam_role" "lambda_role" {
  count = var.custom_role_arn == null ? 1 : 0
  name  = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach selected managed policies
resource "aws_iam_role_policy_attachment" "managed_policy_attachment" {
  for_each = var.custom_role_arn == null ? toset(var.managed_policy_arns) : []
  
  role       = aws_iam_role.lambda_role[0].name
  policy_arn = each.value
}

# Attach custom policies if provided
resource "aws_iam_role_policy" "custom_policy" {
  count = var.custom_role_arn == null && var.custom_policy_json != null ? 1 : 0
  
  name   = "${var.function_name}-custom-policy"
  role   = aws_iam_role.lambda_role[0].name
  policy = var.custom_policy_json
}

# Create trigger permissions if specified
resource "aws_lambda_permission" "trigger" {
  for_each = var.triggers

  statement_id  = each.value.statement_id
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = each.value.principal
  source_arn    = each.value.source_arn
}

# Add event source mapping for Kinesis
resource "aws_lambda_event_source_mapping" "kinesis_trigger" {
  count             = var.kinesis_trigger != null ? 1 : 0
  
  event_source_arn  = var.kinesis_trigger.source_arn
  function_name     = aws_lambda_function.function.arn
  starting_position = "LATEST"
  batch_size        = 100
  enabled           = true
}