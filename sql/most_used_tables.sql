create or replace table
  `${PROJECT_ID}.${DATASET_ID}.most_used_tables` partition by day cluster by user_email as
SELECT
  DATE(CREATION_TIME) AS DAY,
  user_email,
  t.project_id,
  t.dataset_id,
  t.table_id,
  COUNT(*) AS num_references
FROM
    `${PROJECT_ID}.${REGION}.INFORMATION_SCHEMA.JOBS`
  UNNEST(referenced_tables) AS t

GROUP BY
  1,
  user_email,
  t.project_id,
  t.dataset_id,
  t.table_id