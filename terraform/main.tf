terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# EventBridge Rule
resource "aws_cloudwatch_event_rule" "producer_trigger" {
  name                = "weather-producer-trigger"
  description         = "Trigger weather producer Lambda every 3 minutes"
  schedule_expression = "rate(3 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.producer_trigger.name
  target_id = "WeatherProducerLambda"
  arn       = module.weather_producer_lambda.lambda_arn
}

# Producer Lambda
module "weather_producer_lambda" {
  source = "./modules/lambda"

  function_name = "weather-data-producer"
  source_path  = "${path.module}/../producer-real-time"
  handler      = "lambda_function.lambda_handler"
  runtime      = "python3.12"
  
  environment_variables = {
    LATITUDE          = var.latitude
    LONGITUDE         = var.longitude
    TOMORROW_API_KEY  = var.tomorrow_api_key
    KINESIS_NAME      = module.kinesis.stream_name
  }

  # Custom policy for Kinesis PutRecords
  custom_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kinesis:PutRecords",
          "kinesis:PutRecord"
        ]
        Resource = module.kinesis.stream_arn
      }
    ]
  })

  # Add EventBridge trigger permission
  triggers = {
    eventbridge = {
      statement_id = "AllowEventBridgeInvoke"
      principal    = "events.amazonaws.com"
      source_arn   = aws_cloudwatch_event_rule.producer_trigger.arn
    }
  }
}

# Consumer Lambda
module "weather_consumer_lambda" {
  source = "./modules/lambda"

  function_name = "weather-data-consumer"
  source_path  = "${path.module}/../consumer-real-time"
  handler      = "lambda_function.lambda_handler"
  runtime      = "python3.12"
  
  environment_variables = {
    SNS_TOPIC_ARN              = module.sns.topic_arn
    PRECIPITATION_PROBABILITY   = var.precipitation_probability
    RAIN_INTENSITY             = var.rain_intensity
    WIND_GUST                  = var.wind_gust
    WIND_SPEED                 = var.wind_speed
  }

  # Managed policies for Kinesis and basic Lambda execution
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole"
  ]

  # Custom policy for SNS publish
  custom_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = module.sns.topic_arn
      }
    ]
  })

  # Kinesis trigger configuration
  triggers = {
    kinesis = {
      statement_id = "AllowKinesisInvoke"
      principal    = "kinesis.amazonaws.com"
      source_arn   = module.kinesis.stream_arn
    }
  }

  kinesis_trigger = {
    source_arn = module.kinesis.stream_arn
  }
}

# Kinesis Stream
module "kinesis" {
  source = "./modules/kinesis"

  stream_name     = var.kinesis_stream_name
  shard_count     = var.kinesis_shard_count
  retention_period = 24
}

# SNS Topic
module "sns" {
  source = "./modules/sns"

  topic_name        = var.sns_topic_name
  email_subscribers = [var.notification_email]
}