output "lambda_arn" {
  value = aws_lambda_function.function.arn
}

output "lambda_role_arn" {
  value = var.custom_role_arn != null ? var.custom_role_arn : aws_iam_role.lambda_role[0].arn
}

