CREATE OR REPLACE TABLE
  `${PROJECT_ID}.${DATASET_ID}.reservation_utilization_7_days` AS
WITH reservation_slot_capacity AS (
  SELECT
    -- PUBLIC DASHBOARD USE ONLY
    -- Modify this to use the project_id of your administration project as follows:
    -- "{project_id}:{location}."
    CONCAT("${project_id}:${location}.", reservation_name) AS reservation_id,
    change_timestamp AS start_time,
    IFNULL(LEAD(change_timestamp) OVER (PARTITION BY reservation_name ORDER BY change_timestamp ASC),
      CURRENT_TIMESTAMP()) AS end_time,
    action,
    slot_capacity
  FROM
    -- PUBLIC DASHBOARD USE ONLY
    -- Modify this to use your project's INFORMATION_SCHEMA table as follows:
    -- `region-{region_name}`.INFORMATION_SCHEMA.{table}
    `region-{LOCATION}`.INFORMATION_SCHEMA.RESERVATION_CHANGES ),
  latest_slot_capacity AS (
  SELECT
    rcp.reservation_name,
    rcp.slot_capacity,
    -- PUBLIC DASHBOARD USE ONLY
    -- Modify this to use the project_id of your administration project as follows:
    -- "{project_id}:{location}."
    CONCAT("${project_id}:${location}.", rcp.reservation_name) AS reservation_id,
  FROM 
    -- PUBLIC DASHBOARD USE ONLY
    -- Modify this to use your project's INFORMATION_SCHEMA table as follows:
    -- `region-{region_name}`.INFORMATION_SCHEMA.{table}
    `region-{LOCATION}`.INFORMATION_SCHEMA.RESERVATION_CHANGES AS rcp
  WHERE 
    ( rcp.reservation_name, rcp.change_timestamp) IN (
      SELECT AS STRUCT reservation_name, MAX(change_timestamp) 
      FROM 
        -- PUBLIC DASHBOARD USE ONLY
        -- Modify this to use your project's INFORMATION_SCHEMA table as follows:
        -- `region-{region_name}`.INFORMATION_SCHEMA.{table}
       `region-{LOCATION}`.INFORMATION_SCHEMA.RESERVATION_CHANGES
      GROUP BY 
        reservation_name) )
SELECT
  jbo.reservation_id,
  SUM(jbo.total_slot_ms) / (1000 * 60 * 60 * 24 * 7) AS average_weekly_slot_usage,
  AVG(rsc.slot_capacity) AS average_reservation_capacity,
  (SUM(jbo.total_slot_ms) / (1000 * 60 * 60 * 24 * 7)) / AVG(rsc.slot_capacity) AS reservation_utilization,
  lsc.slot_capacity AS latest_capacity
FROM
  -- PUBLIC DASHBOARD USE ONLY
  -- Modify this to use your project's INFORMATION_SCHEMA table as follows:
  -- `region-{region_name}`.INFORMATION_SCHEMA.{table}
  `region-{LOCATION}`.INFORMATION_SCHEMA.JOBS jbo
LEFT JOIN
  reservation_slot_capacity rsc
ON
  jbo.reservation_id = rsc.reservation_id
  AND jbo.creation_time >= rsc.start_time
  AND jbo.creation_time < rsc.end_time
LEFT JOIN
  latest_slot_capacity lsc
ON
  jbo.reservation_id = lsc.reservation_id
WHERE
  -- PUBLIC DASHBOARD USE ONLY
  -- Modify all instances of TIMESTAMP("2020-07-15 23:59:59.000 UTC") with CURRENT_TIMESTAMP()
  jbo.creation_time BETWEEN TIMESTAMP_SUB(TIMESTAMP("2020-07-15 23:59:59.000 UTC"), INTERVAL 8 DAY)
  AND TIMESTAMP("2020-07-15 23:59:59.000 UTC")
  AND jbo.end_time BETWEEN TIMESTAMP_SUB(TIMESTAMP("2020-07-15 23:59:59.000 UTC"), INTERVAL 7 DAY)
  AND TIMESTAMP("2020-07-15 23:59:59.000 UTC")
GROUP BY
  reservation_id,
  lsc.slot_capacity
ORDER BY
  reservation_id DESC