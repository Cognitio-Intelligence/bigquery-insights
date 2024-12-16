CREATE OR REPLACE TABLE
  `${PROJECT_ID}.${DATASET_ID}.job_comparison` AS
SELECT   
    project_id,
    reservation_id,
	cache_hit,
    job_id,
    start_time,
    job_type,
	priority,
    creation_time,
	end_time,
    error_result.reason AS error_reason,
    SUM(total_bytes_processed) AS sum_bytes_processed, 
    SUM(total_slot_ms) AS sum_slot_ms,
	SUM(TIMESTAMP_DIFF(start_time, creation_time, SECOND)) AS creation_sum_sec,
    SUM(TIMESTAMP_DIFF(COALESCE(end_time,CURRENT_TIMESTAMP()), start_time, SECOND)) duration_sum_sec,
    SUM((SELECT SUM(stage.shuffle_output_bytes_spilled) FROM UNNEST(job_stages) stage)) AS shuffle_output_bytes_spilled,
    SUM((SELECT SUM(stage.shuffle_output_bytes) FROM UNNEST(job_stages) stage)) AS shuffle_output_bytes
FROM 
 	-- PUBLIC DASHBOARD USE ONLY
  	-- Modify this to use your project's INFORMATION_SCHEMA table as follows:
  	-- `region-{region_name}`.INFORMATION_SCHEMA.{table}
	`region-{LOCATION}`.INFORMATION_SCHEMA.JOBS
GROUP BY 
	1,2,3,4,5,6,7,8,9,10