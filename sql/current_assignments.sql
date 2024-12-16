CREATE OR REPLACE TABLE
  `${PROJECT_ID}.${DATASET_ID}.current_assignments` AS
WITH latest_slot_capacity as (
 SELECT
   reservation_name, rcp.slot_capacity
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
        reservation_name ) )
SELECT 
  acp.assignment_id, 
  acp.project_id, 
  acp.reservation_name, 
  acp.job_type,
  acp.assignee_id, 
  acp.assignee_type, 
  lsc.slot_capacity
FROM 
  -- PUBLIC DASHBOARD USE ONLY
  -- Modify this to use your project's INFORMATION_SCHEMA table as follows:
  -- `region-{region_name}`.INFORMATION_SCHEMA.{table}
  `region-{LOCATION}`.INFORMATION_SCHEMA.ASSIGNMENT_CHANGES AS acp
LEFT JOIN 
  latest_slot_capacity lsc
ON 
  lsc.reservation_name = acp.reservation_name
GROUP BY 
  acp.assignment_id, 
  acp.project_id, 
  acp.reservation_name, 
  acp.job_type, 
  acp.assignee_id, 
  acp.assignee_type, 
  lsc.slot_capacity 
HAVING COUNT(assignment_id) = 1