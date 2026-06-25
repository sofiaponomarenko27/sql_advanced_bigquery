WITH account_table AS (
   SELECT
       ses.date AS date,
       sp.country,
       ac.send_interval,
       ac.is_verified,
       ac.is_unsubscribed,
       COUNT(DISTINCT ac.id) AS account_cnt
   FROM `data-analytics-mate.DA.account` ac
   JOIN `data-analytics-mate.DA.account_session` acs
       ON ac.id = acs.account_id
   JOIN `data-analytics-mate.DA.session` ses
       ON acs.ga_session_id = ses.ga_session_id
   JOIN `data-analytics-mate.DA.session_params` sp
       ON acs.ga_session_id = sp.ga_session_id
   WHERE sp.country != 'unknown'
   GROUP BY 1,2,3,4,5
),


account_metric AS (
   SELECT
       country,
       SUM(account_cnt) AS total_country_account_cnt,
       DENSE_RANK() OVER (ORDER BY SUM(account_cnt) DESC) AS rank_total_country_account_cnt
   FROM account_table
   GROUP BY 1
),


email_table AS (
   SELECT
       -- якщо ses.date = DATE — тоді це працює
       DATE_ADD(ses.date, INTERVAL es.sent_date DAY) AS date,
       sp.country,
       ac.send_interval,
       ac.is_verified,
       ac.is_unsubscribed,
       COUNT(DISTINCT es.id_message) AS sent_msg,
       COUNT(DISTINCT eo.id_message) AS open_msg,
       COUNT(DISTINCT ev.id_message) AS visit_msg
   FROM `data-analytics-mate.DA.account` ac
   JOIN `data-analytics-mate.DA.email_sent` es
       ON ac.id = es.id_account
   LEFT JOIN `data-analytics-mate.DA.email_open` eo
       ON es.id_message = eo.id_message
   LEFT JOIN `data-analytics-mate.DA.email_visit` ev
       ON es.id_message = ev.id_message
   JOIN `data-analytics-mate.DA.account_session` acs
       ON ac.id = acs.account_id
   JOIN `data-analytics-mate.DA.session` ses
       ON acs.ga_session_id = ses.ga_session_id
   JOIN `data-analytics-mate.DA.session_params` sp
       ON acs.ga_session_id = sp.ga_session_id
   WHERE sp.country != 'unknown'
   GROUP BY 1,2,3,4,5
),


email_metric AS (
   SELECT
       country,
       SUM(sent_msg) AS total_country_sent_cnt,
       DENSE_RANK() OVER (ORDER BY SUM(sent_msg) DESC) AS rank_total_country_sent_cnt
   FROM email_table
   GROUP BY 1
),


union_table AS (
   SELECT
       date,
       country,
       send_interval,
       is_verified,
       is_unsubscribed,
       account_cnt,
       0 AS sent_msg,
       0 AS open_msg,
       0 AS visit_msg
   FROM account_table


   UNION ALL


   SELECT
       date,
       country,
       send_interval,
       is_verified,
       is_unsubscribed,
       0 AS account_cnt,
       sent_msg,
       open_msg,
       visit_msg
   FROM email_table
),


fin_table AS (
   SELECT
       date,
       country,
       send_interval,
       is_verified,
       is_unsubscribed,
       SUM(account_cnt) AS account_cnt,
       SUM(sent_msg) AS sent_msg,
       SUM(open_msg) AS open_msg,
       SUM(visit_msg) AS visit_msg
   FROM union_table
   GROUP BY 1,2,3,4,5
)


SELECT
   fin_table.date,
   fin_table.country,
   fin_table.send_interval,
   fin_table.is_verified,
   fin_table.is_unsubscribed,
   fin_table.account_cnt,
   fin_table.sent_msg,
   fin_table.open_msg,
   fin_table.visit_msg,
   account_metric.total_country_account_cnt,
   email_metric.total_country_sent_cnt,
   account_metric.rank_total_country_account_cnt,
   email_metric.rank_total_country_sent_cnt
FROM fin_table
JOIN account_metric USING (country)
JOIN email_metric USING (country)
WHERE account_metric.rank_total_country_account_cnt <= 10
  OR email_metric.rank_total_country_sent_cnt <= 10;


-- 1. account_table: збираємо акаунти по датах та країнах з характеристиками акаунта
-- 2. account_metric: рахуємо сумарну кількість акаунтів по країнах та ранжуємо їх
-- 3. email_table: збираємо дані по email-розсилках (надіслані, відкриті, переходи) по датах та країнах
-- 4. email_metric: рахуємо сумарну кількість надісланих листів по країнах та ранжуємо їх
-- 5. union_table: об'єднуємо акаунти та email-розсилки в одну таблицю
-- 6. fin_table: сумуємо акаунти та email-метрики по даті, країні та характеристиках
-- 7. Остаточний SELECT: підтягуємо рейтинги по країнах та фільтруємо топ-10 країн за акаунтами або листами
