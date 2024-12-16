CREATE OR REPLACE TABLE
  `${PROJECT_ID}.${DATASET_ID}.job_usage` AS
SELECT
  project_id,
  job_id,
  reservation_id,
  EXTRACT(DATE FROM creation_time) AS creation_date,
  creation_time,
  start_time,
  end_time,
  TIMESTAMP_DIFF(end_time, start_time, SECOND) as job_duration_seconds,
  job_type,
  user_email,
  state,
  error_result,
  total_bytes_processed,
  total_slot_ms / (TIMESTAMP_DIFF(end_time, start_time, MILLISECOND)) AS avg_slots
-- PUBLIC DASHBOARD USE ONLY
-- Modify this to use your project's INFORMATION_SCHEMA table as follows:
-- `region-{region_name}`.INFORMATION_SCHEMA.{table}
FROM `region-{LOCATION}`.INFORMATION_SCHEMA.JOBS
ORDER BY creation_time DESC