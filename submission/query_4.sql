WITH
  today AS (
    SELECT
      user_id,
      browser_type,
      dates_active,
      date
    FROM
      lsleena.user_devices_cumulated
    WHERE
      date = DATE('2023-01-07')  -- select data for the current date (2023-01-07)
  ),
  date_list_int AS (
    SELECT
      user_id,
      browser_type,
      CAST(
        SUM(
          CASE
            -- Calculating the integer representation of activity history using bitwise operations
            WHEN CONTAINS(dates_active, sequence_date) THEN POW(2, 31 - DATE_DIFF('day', sequence_date, date))
            ELSE 0
          END
        ) AS BIGINT
      ) AS history_int
    FROM
      today
      CROSS JOIN UNNEST (SEQUENCE(DATE('2023-01-01'), DATE('2023-01-07'))) AS t (sequence_date) -- Generating a sequence of dates from 2023-01-01 to 2023-01-07
    GROUP BY
      user_id,
      browser_type
  )
SELECT -- Selecting user_id, browser_type, activity history as integer, and activity history in binary
  user_id,
  browser_type,
  history_int,
  TO_BASE(history_int, 2) AS history_in_binary  -- Converting activity history to binary
FROM
  date_list_int
