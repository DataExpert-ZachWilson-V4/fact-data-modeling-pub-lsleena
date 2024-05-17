INSERT INTO lsleena.user_devices_cumulated
WITH yesterday AS
            (
                   SELECT *
                   FROM   lsleena.user_devices_cumulated
                   WHERE  date = date('2022-12-31')
            )
            , -- get previous day data
            today AS
            (
                     SELECT   user_id,
                              browser_type,
                              count(1)                              AS cnt,
                              date( cast(event_time AS timestamp) ) AS date_active
                     FROM     bootcamp.web_events we
                     JOIN     bootcamp.devices d
                     ON       we.device_id = d.device_id
                     WHERE    date( cast(event_time AS timestamp) ) = date('2023-01-01') -- get current day data
                     GROUP BY 1,
                              2,
                              4
            )SELECT          COALESCE( yest.user_id, tday.user_id )           AS user_id,
                   COALESCE( yest.browser_type, tday.browser_type ) AS browser_type,
                   CASE
                                   WHEN yest.dates_active IS NULL THEN array[tday.date_active]
                                   WHEN tday.date_active IS NULL THEN yest.dates_active
                                   ELSE array[tday.date_active]
                                                                   || yest.dates_active
                   END                                                         AS dates_active, -- based on dates_active between yesterday's dates_active and today dates_active populate date_active
                   COALESCE( tday.date_active, date_add('day', 1, yest.date) ) AS date
   FROM            today tday
   FULL OUTER JOIN yesterday yest
   ON              tday.user_id = yest.user_id
   AND             tday.browser_type = yest.browser_type