
# Get Terraform output values
Write-Host "Getting Terraform outputs..."
Set-Location ..\terraform

# Get crawler and job names from Terraform output
$RAW_CRAWLER = terraform output -raw raw_crawler_name
$GOLD_CRAWLER = terraform output -raw gold_crawler_name
$ETL_JOB = terraform output -raw glue_job_name

if (-not ($RAW_CRAWLER -and $GOLD_CRAWLER -and $ETL_JOB)) {
    Write-Host "Error: Could not get required values from Terraform output"
    exit 1
}

Write-Host "Using values from Terraform:"
Write-Host "RAW_CRAWLER: $RAW_CRAWLER"
Write-Host "GOLD_CRAWLER: $GOLD_CRAWLER"
Write-Host "ETL_JOB: $ETL_JOB"

# Function to wait for crawler to complete
function Wait-Crawler {
    param($crawlerName)
    Write-Host "Waiting for crawler ${crawlerName} to complete..."
    
    while ($true) {
        $status = aws glue get-crawler --name $crawlerName --query 'Crawler.State' --output text
        if ($status -eq "READY") {
            break
        }
        Write-Host "Crawler status: $status"
        Start-Sleep -Seconds 30
    }
    
    Write-Host "Crawler ${crawlerName} completed!"
}

# Function to wait for job to complete
function Wait-Job {
    param($jobName, $runId)
    Write-Host "Waiting for job ${jobName} to complete..."
    
    while ($true) {
        $status = aws glue get-job-run --job-name $jobName --run-id $runId --query 'JobRun.JobRunState' --output text
        if ($status -in @("SUCCEEDED", "FAILED", "ERROR")) {
            break
        }
        Write-Host "Job status: $status"
        Start-Sleep -Seconds 30
    }
    
    if ($status -ne "SUCCEEDED") {
        Write-Host "Job failed with status: $status"
        exit 1
    }
    
    Write-Host "Job ${jobName} completed successfully!"
}

Write-Host "Starting Glue workflow..."

# Start and wait for RAW crawler
Write-Host "Starting RAW crawler..."
aws glue start-crawler --name $RAW_CRAWLER
Wait-Crawler $RAW_CRAWLER

# Start and wait for ETL job
Write-Host "Starting ETL job..."
$runId = aws glue start-job-run --job-name $ETL_JOB --query 'JobRunId' --output text
Wait-Job $ETL_JOB $runId

# Start and wait for GOLD crawler
Write-Host "Starting GOLD crawler..."
aws glue start-crawler --name $GOLD_CRAWLER
Wait-Crawler $GOLD_CRAWLER

Write-Host "Glue workflow completed successfully!"