-- Your first scheduled query
CREATE OR REPLACE TABLE
  `${PROJECT_ID}.${DATASET_ID}.daily_usage`
PARTITION BY
  day
CLUSTER BY
  user_email AS
SELECT
  DATE(creation_time) AS day,
  user_email,
  SUM(total_bytes_processed)/1099511627776 AS daily_tb_processed,
  SUM(total_bytes_billed)/1099511627776 AS daily_tb_billed,
FROM
    `${PROJECT_ID}.${REGION}.INFORMATION_SCHEMA.JOBS`

WHERE
  AND job_type = 'QUERY'
  AND state = 'DONE'
  AND statement_type != 'SCRIPT'
GROUP BY
  1,
  2