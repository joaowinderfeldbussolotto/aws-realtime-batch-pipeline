# IAM Role para o Glue Job

resource "aws_s3_object" "glue_script" {
  bucket = var.scripts_bucket_name
  key    = "scripts/${var.job_name}.py"
  source = var.local_script_path
  etag   = filemd5(var.local_script_path)
}


resource "aws_iam_role" "glue_job_role" {
  name = var.glue_job_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_job_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.glue_job_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_full_access" {
  role       = aws_iam_role.glue_job_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# Add explicit S3 permissions to Glue role
resource "aws_iam_role_policy" "s3_policy" {
  name = "${var.glue_job_role_name}-s3-policy"
  role = aws_iam_role.glue_job_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${split("/", var.raw_data_path)[2]}",
          "arn:aws:s3:::${split("/", var.raw_data_path)[2]}/*"
        ]
      }
    ]
  })
}

# Create S3 directories
resource "aws_s3_object" "raw_prefix" {
  bucket  = split("/", var.raw_data_path)[2]
  key     = "raw/"
  content = ""  # Empty content instead of source file
}

resource "aws_s3_object" "gold_prefix" {
  bucket  = split("/", var.raw_data_path)[2]
  key     = "gold/"
  content = ""  # Empty content instead of source file
}

# Glue Job
resource "aws_glue_job" "etl_job" {
  name              = var.job_name
  role_arn          = aws_iam_role.glue_job_role.arn
  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 2
  timeout           = var.timeout

  command {
    script_location = "s3://${var.scripts_bucket_name}/scripts/${var.job_name}.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                    = "python"
    "--continuous-log-logGroup"         = "/aws-glue/jobs/${var.job_name}"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"                  = "true"
  }
}


# Glue Crawler para Raw
resource "aws_glue_crawler" "raw_crawler" {
  database_name = var.raw_database_name
  name          = var.raw_crawler_name
  role          = aws_iam_role.glue_job_role.arn

  s3_target {
    path = var.raw_data_path
  }

  configuration = jsonencode({
    Version = 1.0
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
  })

  depends_on = [aws_s3_object.raw_prefix, aws_iam_role_policy.s3_policy]
}

# Glue Crawler para Gold
resource "aws_glue_crawler" "gold_crawler" {
  database_name = var.gold_database_name
  name          = var.gold_crawler_name
  role          = aws_iam_role.glue_job_role.arn

  s3_target {
    path = var.gold_data_path
  }

  configuration = jsonencode({
    Version = 1.0
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
  })

  depends_on = [aws_s3_object.gold_prefix, aws_iam_role_policy.s3_policy]
}

# Glue Database - Raw
resource "aws_glue_catalog_database" "raw_database" {
  name = var.raw_database_name
}

# Glue Database - Gold
resource "aws_glue_catalog_database" "gold_database" {
  name = var.gold_database_name
}


