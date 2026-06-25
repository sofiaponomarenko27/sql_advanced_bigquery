# 📊 SQL Advanced: Window Functions in BigQuery

## Task Description

Analyze email sending activity per account per month using **window functions only** (no `GROUP BY`).

**Requirements:**
- Calculate the percentage of emails sent by each account within a given month relative to the total emails sent that month
- Determine the first and last email sending date for each account within a given month

---

## Dataset

**Source:** `data-analytics-mate.DA` (Google BigQuery)

**Tables used:**

| Table | Description |
|---|---|
| `email_sent` | Email sending log (account ID, message ID, relative sent date) |
| `account` | Account reference data |
| `account_session` | Mapping between accounts and sessions |
| `session` | Session data with absolute start date |

> The actual send date is reconstructed by adding `sent_date` (days offset) to the session's start date via `DATE_ADD(s.date, INTERVAL es.sent_date DAY)`.

---

## Solution

```sql
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
```

---

## Key Techniques

| Technique | Usage |
|---|---|
| `COUNT() OVER (PARTITION BY ...)` | Count emails per account/month and per month total — simultaneously, without GROUP BY |
| `MIN() / MAX() OVER (PARTITION BY ...)` | First and last send date per account per month |
| `NULLIF(..., 0)` | Prevents division-by-zero errors |
| `DATE_TRUNC(..., MONTH)` | Truncates reconstructed dates to month granularity |
| `DATE_ADD(s.date, INTERVAL es.sent_date DAY)` | Reconstructs the absolute send date from a relative offset |
| `DISTINCT` | Deduplicates rows after window function expansion |
| 4-table `JOIN` | Connects sending events to sessions via account mapping |

---

## Output Format

| Column | Description |
|---|---|
| `sent_month` | First day of the month (e.g. `2021-02-01`) |
| `id_account` | Account identifier |
| `sent_msg` | Number of emails sent by this account in this month |
| `sent_msg_month` | Total emails sent by all accounts in this month |
| `sent_msg_percent_from_this_month` | Share of this account's emails in the month total (%) |
| `first_sent_date` | Date of the first email sent by this account in this month |
| `last_sent_date` | Date of the last email sent by this account in this month |

---

## Tools

![BigQuery](https://img.shields.io/badge/Google_BigQuery-4285F4?style=flat&logo=googlebigquery&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Window_Functions-informational?style=flat)
