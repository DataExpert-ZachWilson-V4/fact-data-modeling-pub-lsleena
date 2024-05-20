INSERT INTO
  lsleena.host_activity_reduced  -- insert data into the host_activity_reduced
WITH
  yesterday AS ( -- CTE to fetch data for the previous month start
    SELECT
      host,                      
      metric_name,              
      metric_array,
      month_start
    FROM
      lsleena.host_activity_reduced
    WHERE
      month_start = '2023-01-01' -- Filtering for the start of the month
  ),
  today AS ( -- CTE to fetch data for the current day
    SELECT
      host,                      
      metric_name,              
      metric_value,              
      DATE
    FROM
      lsleena.daily_web_metrics
    WHERE
      DATE = DATE('2023-01-02')  -- Filtering for the current date
  )
SELECT
  COALESCE(t.host, y.host) AS host,
  COALESCE(t.metric_name, y.metric_name) AS metric_name,
  COALESCE(
    y.metric_array,  -- If the metric_array exists from yesterday otherwise create an array of nulls with the difference in days
    REPEAT(
      NULL,
      CAST(
        DATE_DIFF('day', DATE('2023-01-01'), t.date) AS INTEGER
      )
    )
  ) || ARRAY[t.metric_value] AS metric_array,
  '2023-01-01' AS month_start
FROM
  today t
  FULL OUTER JOIN yesterday y ON t.host = y.host  
  AND t.metric_name = y.metric_name  -- joining today's and yesterday's data