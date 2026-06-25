# SQL Advanced: BigQuery Portfolio

A collection of SQL scripts written in Google BigQuery as part of the **SQL Advanced** module.  
Each script solves a real analytical task using advanced SQL techniques.

## Tech Stack

![BigQuery](https://img.shields.io/badge/Google_BigQuery-4285F4?style=flat&logo=googlebigquery&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Advanced-informational?style=flat)

---

## Projects

| # | Topic | Task | Key Techniques |
|---|-------|------|----------------|
| 1 | [Window Functions](./window_functions/) | [Emails Sent by Month](./window_functions/README.md) | `COUNT OVER`, `MIN/MAX OVER`, `DATE_TRUNC`, `NULLIF` |
| 2 | [CTEs](./cte/) | [Revenue by Device and Continent](./cte/README.md) | `WITH AS`, `SUM(CASE WHEN)`, `SUM() OVER ()`, `COUNT DISTINCT` |
| 3 | [Datetime Functions](./datetime_functions/) | [Revenues and Costs by Year and Month](./datetime_functions/README.md) | `EXTRACT`, `UNION ALL`, subquery, `JOIN` |
| 4 | [Nested Fields](./nested_fields/) | [YouTube Events](./nested_fields/README.md) | `CROSS JOIN UNNEST`, `LIKE`, `LOWER`, `SUM(CASE WHEN)` |
| 5 | [Final Project](./final_project/) | [Email Campaign Analysis](./final_project/README.md) | 5x CTEs, `DENSE_RANK`, `UNION ALL`, `LEFT JOIN`, `DATE_ADD` |

---

## Repository Structure

sql_advanced_bigquery/

│

├── README.md                                        ← you are here

│

├── window_functions/

│   ├── emails_sent_by_month.sql

│   └── README.md

│

├── cte/

│   ├── revenue_by_device_and_continent.sql

│   └── README.md

│

├── datetime_functions/

│   ├── revenues_and_costs_by_year_and_month.sql

│   └── README.md

│

├── nested_fields/

│   ├── youtube_events.sql

│   └── README.md

│

└── final_project/

├── email_campaign_analysis.sql

└── README.md


└── README.md

└── README.md
