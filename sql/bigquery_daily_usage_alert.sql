IF EXISTS(
  SELECT
    size_bytes
  FROM
    `${PROJECT_ID}.${DATASET_ID}.__TABLES__`
  WHERE
    table_id='bigquery_daily_usage_alert') THEN
CREATE OR REPLACE TABLE
  `${PROJECT_ID}.${DATASET_ID}.bigquery_daily_usage_alert`
PARTITION BY
  day
CLUSTER BY
  user_email AS
WITH
  a AS (
  SELECT
    DATE(creation_time) AS day,
    user_email,
    SUM(total_bytes_billed)/1099511627776 AS daily_tb_billed,
    CASE
      WHEN SUM(total_bytes_billed)/1099511627776 > 1 THEN 1
      ELSE 0
  END
    AS checklist_1_tb,
    CASE
      WHEN SUM(total_bytes_billed)/1099511627776 > 3 THEN 1
      ELSE 0
  END
    AS checklist_3_tb,
    CASE
      WHEN SUM(total_bytes_billed)/1099511627776 > 5 THEN 1
      ELSE 0
  END
    AS checklist_5_tb,
    CASE
      WHEN SUM(total_bytes_billed)/1099511627776 > 10 THEN 1
      ELSE 0
  END
    AS checklist_10_tb,
    CASE
      WHEN SUM(total_bytes_billed)/1099511627776 > 20 THEN 1
      ELSE 0
  END
    AS checklist_20_tb,
  FROM
     `${PROJECT_ID}.${REGION}.INFORMATION_SCHEMA.JOBS_BY_PROJECT`
  WHERE
    DATE(creation_time) = CURRENT_DATE
    AND job_type = 'QUERY'
    AND state = 'DONE'
    AND statement_type != 'SCRIPT'
  GROUP BY
    1,
    2),
  b AS (
  SELECT
    a.day,
    a.user_email,
    a.daily_tb_billed,
    a.checklist_1_tb,
    lagged_checklist_1_tb,
    a.checklist_3_tb,
    lagged_checklist_3_tb,
    a.checklist_5_tb,
    lagged_checklist_5_tb,
    a.checklist_10_tb,
    lagged_checklist_10_tb,
    a.checklist_20_tb,
    lagged_checklist_20_tb,
  FROM
    a
  LEFT JOIN (
    SELECT
      user_email,
      checklist_1_tb AS lagged_checklist_1_tb,
      checklist_3_tb AS lagged_checklist_3_tb,
      checklist_5_tb AS lagged_checklist_5_tb,
      checklist_10_tb AS lagged_checklist_10_tb,
      checklist_20_tb AS lagged_checklist_20_tb,
    FROM
      `${PROJECT_ID}.${DATASET_ID}.bigquery_daily_usage_alert`) al
  ON
    a.user_email = al.user_email)
SELECT
  DISTINCT *,
  CASE
    WHEN lagged_checklist_1_tb = 0 AND checklist_1_tb = 1 THEN 1
    ELSE 0
END
  AS query_1_tb_limit,
  CASE
    WHEN lagged_checklist_3_tb = 0 AND checklist_3_tb = 1 THEN 1
    ELSE 0
END
  AS query_3_tb_limit,
  CASE
    WHEN lagged_checklist_5_tb = 0 AND checklist_5_tb = 1 THEN 1
    ELSE 0
END
  AS query_5_tb_limit,
  CASE
    WHEN lagged_checklist_10_tb = 0 AND checklist_10_tb = 1 THEN 1
    ELSE 0
END
  AS query_10_tb_limit,
  CASE
    WHEN lagged_checklist_20_tb = 0 AND checklist_20_tb = 1 THEN 1
    ELSE 0
END
  AS query_20_tb_limit,
FROM
  b;
    ELSE
CREATE OR REPLACE TABLE
  `${PROJECT_ID}.${DATASET_ID}.bigquery_daily_usage_alert`
PARTITION BY
  day
CLUSTER BY
  user_email AS
SELECT
  DATE(creation_time) AS day,
  user_email,
  SUM(total_bytes_billed)/1099511627776 AS daily_tb_billed,
  CASE
    WHEN SUM(total_bytes_billed)/1099511627776 > 1 THEN 1
    ELSE 0
END
  AS checklist_1_tb,
  CASE
    WHEN SUM(total_bytes_billed)/1099511627776 > 3 THEN 1
    ELSE 0
END
  AS checklist_3_tb,
  CASE
    WHEN SUM(total_bytes_billed)/1099511627776 > 5 THEN 1
    ELSE 0
END
  AS checklist_5_tb,
  CASE
    WHEN SUM(total_bytes_billed)/1099511627776 > 10 THEN 1
    ELSE 0
END
  AS checklist_10_tb,
  CASE
    WHEN SUM(total_bytes_billed)/1099511627776 > 20 THEN 1
    ELSE 0
END
  AS checklist_20_tb,
FROM
    `${PROJECT_ID}.${REGION}.INFORMATION_SCHEMA.JOBS_BY_PROJECT`

WHERE
  DATE(creation_time) = CURRENT_DATE
  AND job_type = 'QUERY'
  AND state = 'DONE'
  AND statement_type != 'SCRIPT'
GROUP BY
  1,
  2;
END IF