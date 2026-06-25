# 📊 SQL Advanced: Final Project in BigQuery

## Task Description

Build a consolidated analytical dataset combining account data and email campaign metrics
by country, with ranking of top-10 countries by account count and emails sent.

**Requirements:**
- Collect account data by date, country and account characteristics
- Collect email metrics (sent, opened, visited) by date and country
- Combine both datasets via UNION ALL
- Rank countries by total accounts and total emails sent
- Filter top-10 countries by either metric

---

## Dataset

**Source:** `data-analytics-mate.DA` (Google BigQuery)

**Tables used:**

| Table | Description |
|---|---|
| `account` | Account data with send interval, verification and subscription status |
| `account_session` | Mapping between accounts and sessions |
| `session` | Session data with dates |
| `session_params` | Session parameters including country |
| `email_sent` | Sent email log |
| `email_open` | Opened email log |
| `email_visit` | Email visit (click) log |

---

## Solution

```sql
WITH account_table AS (
  SELECT
    ses.date AS date,
    sp.country,
    ac.send_interval,
    ac.is_verified,
    ac.is_unsubscribed,
    COUNT(DISTINCT ac.id) AS account_cnt
  FROM `data-analytics-mate.DA.account` ac
  JOIN `data-analytics-mate.DA.account_session` acs ON ac.id = acs.account_id
  JOIN `data-analytics-mate.DA.session` ses ON acs.ga_session_id = ses.ga_session_id
  JOIN `data-analytics-mate.DA.session_params` sp ON acs.ga_session_id = sp.ga_session_id
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
    DATE_ADD(ses.date, INTERVAL es.sent_date DAY) AS date,
    sp.country,
    ac.send_interval,
    ac.is_verified,
    ac.is_unsubscribed,
    COUNT(DISTINCT es.id_message) AS sent_msg,
    COUNT(DISTINCT eo.id_message) AS open_msg,
    COUNT(DISTINCT ev.id_message) AS visit_msg
  FROM `data-analytics-mate.DA.account` ac
  JOIN `data-analytics-mate.DA.email_sent` es ON ac.id = es.id_account
  LEFT JOIN `data-analytics-mate.DA.email_open` eo ON es.id_message = eo.id_message
  LEFT JOIN `data-analytics-mate.DA.email_visit` ev ON es.id_message = ev.id_message
  JOIN `data-analytics-mate.DA.account_session` acs ON ac.id = acs.account_id
  JOIN `data-analytics-mate.DA.session` ses ON acs.ga_session_id = ses.ga_session_id
  JOIN `data-analytics-mate.DA.session_params` sp ON acs.ga_session_id = sp.ga_session_id
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
  SELECT date, country, send_interval, is_verified, is_unsubscribed,
    account_cnt, 0 AS sent_msg, 0 AS open_msg, 0 AS visit_msg
  FROM account_table
  UNION ALL
  SELECT date, country, send_interval, is_verified, is_unsubscribed,
    0 AS account_cnt, sent_msg, open_msg, visit_msg
  FROM email_table
),

fin_table AS (
  SELECT
    date, country, send_interval, is_verified, is_unsubscribed,
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
```

---

## Key Techniques

| Technique | Usage |
|---|---|
| 5x `WITH ... AS ()` (CTEs) | Splits complex pipeline into readable stages |
| `DENSE_RANK() OVER ()` | Ranks countries by accounts and emails sent |
| `UNION ALL` | Combines account and email data into one dataset |
| `LEFT JOIN` | Preserves emails without opens/visits |
| `DATE_ADD(..., INTERVAL DAY)` | Reconstructs absolute send date from offset |
| `COUNT(DISTINCT ...)` | Deduplicates accounts and messages |
| `WHERE rank <= 10` | Filters top-10 countries by either metric |

---

## Output Format

| Column | Description |
|---|---|
| `date` | Date of activity |
| `country` | Country |
| `send_interval` | Account's email send interval setting |
| `is_verified` | Account verification status |
| `is_unsubscribed` | Account unsubscription status |
| `account_cnt` | Number of accounts |
| `sent_msg` | Emails sent |
| `open_msg` | Emails opened |
| `visit_msg` | Emails clicked/visited |
| `total_country_account_cnt` | Total accounts for this country |
| `total_country_sent_cnt` | Total emails sent for this country |
| `rank_total_country_account_cnt` | Country rank by accounts |
| `rank_total_country_sent_cnt` | Country rank by emails sent |

---

## Tools

![BigQuery](https://img.shields.io/badge/Google_BigQuery-4285F4?style=flat&logo=googlebigquery&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Final_Project-informational?style=flat)
