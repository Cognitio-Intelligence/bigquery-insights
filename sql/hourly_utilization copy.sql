CREATE OR REPLACE TABLE
  `${PROJECT_ID}.${DATASET_ID}.hourly_utilization` AS
SELECT
  TIMESTAMP_TRUNC(jbo.creation_time, HOUR) as usage_time,
  EXTRACT(DATE from jbo.creation_time) as usage_date,
  jbo.reservation_id,
  jbo.project_id,
  jbo.job_type,
  jbo.user_email,
  SUM(jbo.total_slot_ms) / (1000 * 60 * 60) as average_hourly_slot_usage,
FROM
  -- PUBLIC DASHBOARD USE ONLY
  -- Modify this to use your project's INFORMATION_SCHEMA table as follows:
  -- `region-{region_name}`.INFORMATION_SCHEMA.{table}
    `region-{LOCATION}`.INFORMATION_SCHEMA.JOBS jbo
GROUP BY
  usage_time,
  usage_date,
  jbo.project_id,
  jbo.reservation_id,
  jbo.job_type,
  jbo.user_email
ORDER BY
  usage_time ASC