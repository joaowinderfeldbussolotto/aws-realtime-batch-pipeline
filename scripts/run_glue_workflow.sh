#!/bin/bash

# Get Terraform output values
echo "Getting Terraform outputs..."
cd ../terraform

# Get crawler and job names from Terraform output
RAW_CRAWLER=$(terraform output -raw raw_crawler_name)
GOLD_CRAWLER=$(terraform output -raw gold_crawler_name)
ETL_JOB=$(terraform output -raw glue_job_name)

if [ -z "$RAW_CRAWLER" ] || [ -z "$GOLD_CRAWLER" ] || [ -z "$ETL_JOB" ]; then
    echo "Error: Could not get required values from Terraform output"
    exit 1
fi

echo "Using values from Terraform:"
echo "RAW_CRAWLER: $RAW_CRAWLER"
echo "GOLD_CRAWLER: $GOLD_CRAWLER"
echo "ETL_JOB: $ETL_JOB"

# Function to wait for crawler to complete
wait_for_crawler() {
    local crawler_name=$1
    echo "Waiting for crawler ${crawler_name} to complete..."
    
    while true; do
        status=$(aws glue get-crawler --name "$crawler_name" --query 'Crawler.State' --output text)
        if [ "$status" = "READY" ]; then
            break
        fi
        echo "Crawler status: $status"
        sleep 30
    done
    
    echo "Crawler ${crawler_name} completed!"
}

# Function to wait for job to complete
wait_for_job() {
    local job_name=$1
    local run_id=$2
    echo "Waiting for job ${job_name} to complete..."
    
    while true; do
        status=$(aws glue get-job-run --job-name "$job_name" --run-id "$run_id" --query 'JobRun.JobRunState' --output text)
        if [[ "$status" == "SUCCEEDED" || "$status" == "FAILED" || "$status" == "ERROR" ]]; then
            break
        fi
        echo "Job status: $status"
        sleep 30
    done
    
    if [ "$status" != "SUCCEEDED" ]; then
        echo "Job failed with status: $status"
        exit 1
    fi
    
    echo "Job ${job_name} completed successfully!"
}

echo "Starting Glue workflow..."

# Start and wait for RAW crawler
echo "Starting RAW crawler..."
aws glue start-crawler --name "$RAW_CRAWLER"
wait_for_crawler "$RAW_CRAWLER"

# Start and wait for ETL job
echo "Starting ETL job..."
run_id=$(aws glue start-job-run --job-name "$ETL_JOB" --query 'JobRunId' --output text)
wait_for_job "$ETL_JOB" "$run_id"

# Start and wait for GOLD crawler
echo "Starting GOLD crawler..."
aws glue start-crawler --name "$GOLD_CRAWLER"
wait_for_crawler "$GOLD_CRAWLER"

echo "Glue workflow completed successfully!"