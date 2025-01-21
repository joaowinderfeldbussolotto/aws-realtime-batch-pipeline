output "weather_producer_lambda" {
  value = module.weather_producer_lambda.lambda_arn
}

output "weather_consumer_lambda_arn" {
  value = module.weather_consumer_lambda.lambda_arn
}

output "sns_topic_arn" {
  value = module.sns.topic_arn
}

output "kinesis_stream_arn" {
  value = module.kinesis.stream_arn
}