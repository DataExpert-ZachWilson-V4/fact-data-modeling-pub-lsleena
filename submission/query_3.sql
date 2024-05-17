INSERT INTO lsleena.user_devices_cumulated
WITH yesterday AS
            (
                   SELECT *
                   FROM   lsleena.user_devices_cumulated
                   WHERE  date = date('2022-12-31')
            ),
            today AS
            (
                     SELECT   user_id,
                              browser_type,
                              count(1)                              AS cnt,
                              date_trunc('day', event_time) AS date_active
                     FROM     bootcamp.web_events we
                     JOIN     bootcamp.devices d
                     ON       we.device_id = d.device_id
                     WHERE    date_trunc('day', event_time) = date('2023-01-01')
                     GROUP BY 1,
                              2,
                              4
            )
SELECT          COALESCE( yesterday.user_id, today.user_id )           AS user_id,
                   COALESCE( yesterday.browser_type, today.browser_type ) AS browser_type,
                   CASE
                                   WHEN yesterday.dates_active IS NULL THEN array[today.date_active]
                                   WHEN today.date_active IS NULL THEN yesterday.dates_active
                                   ELSE array[today.date_active]
                                                                   || yesterday.dates_active
                   END                                                         AS dates_active,
                   COALESCE( today.date_active, date_add('day', 1, yesterday.date) ) AS date
   FROM            today
   FULL OUTER JOIN yesterday
   ON              today.user_id = yesterday.user_id
   AND             today.browser_type = yesterday.browser_type