-- Your first scheduled query
CREATE OR REPLACE TABLE
   `${PROJECT_ID}.${DATASET_ID}.scheduled_query_errors`
PARTITION BY
  day
CLUSTER BY
  user_email AS
SELECT
 DATE(creation_time) AS day,
  job_id,
  creation_time,
  user_email,
  error_result
FROM
  `${PROJECT_ID}.${REGION}.INFORMATION_SCHEMA.JOBS_BY_PROJECT`
WHERE
  error_result.reason != "Null"
  AND job_id LIKE "%scheduled_query%"
ORDER BY
  creation_time DESC