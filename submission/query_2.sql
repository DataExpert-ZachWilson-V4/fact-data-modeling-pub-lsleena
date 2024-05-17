CREATE OR REPLACE TABLE lsleena.user_devices_cumulated (
    user_id bigint,
    browser_type varchar,
    dates_active array(date),
    date date
)
with (FORMAT = 'PARQUET', partitioning = Array['date'])