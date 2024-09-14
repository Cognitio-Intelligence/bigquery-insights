#!/bin/bash
# Script to set up the project, enable APIs, create scheduled queries, etc.

# Enable required APIs
gcloud services enable bigquery.googleapis.com
gcloud services enable bigquerydatatransfer.googleapis.com

# Create BigQuery dataset
bq mk --dataset "${PROJECT_ID}:${DATASET_ID}"

# Create scheduled queries
bq query --use_legacy_sql=false --schedule="every 24 hours" < sql/avg_slot_usage.sql
bq query --use_legacy_sql=false --schedule="every 15 minutes" < sql/bigquery_daily_usage_alert.sql
bq query --use_legacy_sql=false --schedule="every 24 hours" < sql/daily_usage.sql
bq query --use_legacy_sql=false --schedule="every 24 hours" < sql/most_used_tables.sql
bq query --use_legacy_sql=false --schedule="every 24 hours" < sql/scheduled_query_errors.sql
bq query --use_legacy_sql=false --schedule="every 24 hours" < sql/tb_billed_hourly.sql

echo "Setup complete. Please configure AppScript and import the dashboard template manually."
