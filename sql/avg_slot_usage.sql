CREATE OR REPLACE TABLE
  `${PROJECT_ID}.${DATASET_ID}.last_avg_slots` AS
SELECT
  user_email,
  SUM(total_slot_ms) AS sum_slots
FROM
  `${PROJECT_ID}.${REGION}.INFORMATION_SCHEMA.JOBS`
WHERE
  -- Filter by the partition column first to limit the amount of data scanned.
  -- Eight days allows for jobs created before the 7 day end_time filter.
  creation_time BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 8 DAY) AND CURRENT_TIMESTAMP()
  AND job_type = 'QUERY'
  AND statement_type != 'SCRIPT'
  AND end_time BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY) AND CURRENT_TIMESTAMP()
GROUP BY
  1;