SELECT
  DISTINCT
  DATE_TRUNC(DATE_ADD(s.date, INTERVAL es.sent_date DAY), MONTH) AS sent_month,
  es.id_account AS id_account,
  COUNT(es.id_message) OVER (
    PARTITION BY es.id_account,
    DATE_TRUNC(DATE_ADD(s.date, INTERVAL es.sent_date DAY), MONTH)
  ) AS sent_msg,
  COUNT(es.id_message) OVER (
    PARTITION BY DATE_TRUNC(DATE_ADD(s.date, INTERVAL es.sent_date DAY), MONTH)
  ) AS sent_msg_month,
  ROUND(
    COUNT(es.id_message) OVER (
      PARTITION BY es.id_account,
      DATE_TRUNC(DATE_ADD(s.date, INTERVAL es.sent_date DAY), MONTH)
    )
    * 100.0
    / NULLIF(
        COUNT(es.id_message) OVER (
          PARTITION BY DATE_TRUNC(DATE_ADD(s.date, INTERVAL es.sent_date DAY), MONTH)
        ), 0)
  , 2) AS sent_msg_percent_from_this_month,
  MIN(DATE_ADD(s.date, INTERVAL es.sent_date DAY)) OVER (
    PARTITION BY es.id_account,
    DATE_TRUNC(DATE_ADD(s.date, INTERVAL es.sent_date DAY), MONTH)
  ) AS first_sent_date,
  MAX(DATE_ADD(s.date, INTERVAL es.sent_date DAY)) OVER (
    PARTITION BY es.id_account,
    DATE_TRUNC(DATE_ADD(s.date, INTERVAL es.sent_date DAY), MONTH)
  ) AS last_sent_date
FROM data-analytics-mate.DA.email_sent es
JOIN data-analytics-mate.DA.account a
  ON es.id_account = a.id
JOIN data-analytics-mate.DA.account_session acs
  ON a.id = acs.account_id
JOIN data-analytics-mate.DA.session s
  ON acs.ga_session_id = s.ga_session_id
ORDER BY sent_month, id_account;
