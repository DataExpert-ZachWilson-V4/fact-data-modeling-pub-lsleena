CREATE OR REPLACE TABLE lsleena.host_activity_reduced
(
    host VARCHAR,
    metric_name VARCHAR,
    metric_array array(INTEGER),
    month_start VARCHAR
)
with (FORMAT = 'PARQUET', partitioning = Array['month_start'])