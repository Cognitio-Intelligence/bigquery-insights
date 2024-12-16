CREATE OR REPLACE TABLE
  `${PROJECT_ID}.${DATASET_ID}.job_errors` AS
SELECT
  project_id,
  user_email, 
  creation_time,
  job_type,
  CASE WHEN statement_type IS NULL THEN 'N/A' ELSE statement_type END AS statement_type,
  error_result 
-- PUBLIC DASHBOARD USE ONLY
-- Modify this to use your project's INFORMATION_SCHEMA table as follows:
-- `region-{region_name}`.INFORMATION_SCHEMA.{table}
FROM `region-{LOCATION}`.INFORMATION_SCHEMA.JOBS
WHERE error_result.reason IS NOT NULL