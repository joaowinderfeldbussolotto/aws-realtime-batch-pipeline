output "job_name" {
  value = aws_glue_job.etl_job.name
}

output "job_role_arn" {
  value = aws_iam_role.glue_job_role.arn
}


output "raw_crawler_name" {
  value = aws_glue_crawler.raw_crawler.name
}

output "gold_crawler_name" {
  value = aws_glue_crawler.gold_crawler.name
}

