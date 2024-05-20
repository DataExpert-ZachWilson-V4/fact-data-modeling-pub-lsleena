INSERT INTO lsleena.user_devices_cumulated
WITH yesterday AS
            (
                   SELECT *
                   FROM   lsleena.hosts_cumulated
                   WHERE  date = date('2022-12-31')
            ),
            today AS
            (
                     SELECT   host,
                              CAST(date_trunc('day', event_time) AS DATE) AS event_date,  -- Truncating event_time to get the event_date
                              COUNT(1) AS activity_count              -- Counting the number of events for each host and date
                     FROM
                        bootcamp.web_events
                     WHERE
                        date_trunc('day', event_time) = date('2023-01-01')
                     GROUP BY
                        host, CAST(date_trunc('day', event_time) AS DATE)  -- Grouping by host and event date
            )
SELECT          COALESCE( yesterday.host, today.host )           AS host,
                   CASE
                                   WHEN yesterday.host_activity_datelist IS NULL THEN array[today.event_date]
                                   WHEN today.event_date IS NULL THEN yesterday.host_activity_datelist
                                   ELSE array[today.event_date]
                                                                   || yesterday.host_activity_datelist
                   END                                                         AS host_activity_datelist,
     DATE('2023-01-01') AS DATE
        FROM            today
   FULL OUTER JOIN yesterday
   ON              today.host = yesterday.host