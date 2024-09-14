-- Your first scheduled query
CREATE OR REPLACE TABLE
  `${PROJECT_ID}.${DATASET_ID}.tb_billed_hourly`
PARTITION BY
  day
CLUSTER BY
  user_email AS
SELECT
  DATE(creation_time) AS day,
  user_email,
  TIMESTAMP_TRUNC(end_time, HOUR) AS time_window,
  SUM(total_bytes_billed)/1099511627776 AS tb_billed,
FROM
  `${PROJECT_ID}.${REGION}.INFORMATION_SCHEMA.JOBS`
WHERE
  job_type = 'QUERY'
  AND statement_type != 'SCRIPT'
GROUP BY
  day,
  user_email,
  time_window
