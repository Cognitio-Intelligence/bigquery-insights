CREATE OR REPLACE TABLE
  `${PROJECT_ID}.${DATASET_ID}.commitments_timeline` AS
WITH
  commitments AS (
    SELECT
      change_timestamp,
      commitment_plan,
      action,
      EXTRACT(DATE FROM change_timestamp) AS start_date,
      IFNULL(
        LEAD(DATE_SUB(EXTRACT(DATE FROM change_timestamp), INTERVAL 1 DAY))
          OVER (PARTITION BY state ORDER BY change_timestamp),
        CURRENT_DATE()) AS stop_date,
      SUM(CASE WHEN cccp.action = 'UPDATE' THEN cccp.slot_count ELSE cccp.slot_count * -1 END)
        OVER (
          PARTITION BY state
          ORDER BY change_timestamp ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS slot_cummulative,
      ROW_NUMBER()
        OVER (
          PARTITION BY EXTRACT(DATE FROM change_timestamp)
          ORDER BY change_timestamp DESC
        ) AS rn
    FROM
      -- PUBLIC DASHBOARD USE ONLY
  	  -- Modify this to use your project's INFORMATION_SCHEMA table as follows:
      -- `region-{region_name}`.INFORMATION_SCHEMA.{table}
      `region-{LOCATION}`.INFORMATION_SCHEMA.CAPACITY_COMMITMENT_CHANGES AS cccp
    WHERE
      state = 'ACTIVE'
      AND commitment_plan != 'FLEX'
    ORDER BY change_timestamp
  ),
  results AS (SELECT * FROM commitments WHERE rn = 1),
  days AS (
    SELECT day
    FROM (
       SELECT
         start_date,
         stop_date
       FROM results
     ), UNNEST(GENERATE_DATE_ARRAY(start_date, stop_date)) day
  )
SELECT TIMESTAMP(day) as date, LAST_VALUE(slot_cummulative IGNORE NULLS) OVER(ORDER BY day) slots,
FROM days
LEFT JOIN results
  ON day = DATE(change_timestamp)