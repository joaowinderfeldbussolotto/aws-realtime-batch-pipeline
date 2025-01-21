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

output "raw_crawler_name" {
  value = module.glue_etl.raw_crawler_name
}

output "gold_crawler_name" {
  value = module.glue_etl.gold_crawler_name
}

output "glue_job_name" {
  value = module.glue_etl.job_name
}