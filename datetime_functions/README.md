# 📊 SQL Advanced: Datetime Functions in BigQuery

## Task Description

Group revenues and costs by year and month using datetime functions.

**Requirements:**
- Extract year and month from dates
- Calculate total revenue from orders per date
- Calculate total cost from paid search per date
- Combine both into a single result using UNION ALL

---

## Dataset

**Source:** `data-analytics-mate.DA` (Google BigQuery)

**Tables used:**

| Table | Description |
|---|---|
| `paid_search_cost` | Daily paid search costs |
| `order` | Order log linked to sessions |
| `product` | Product data with prices |
| `session` | Session data with dates |

---

## Solution

```sql
SELECT
  EXTRACT(YEAR FROM date) AS year,
  EXTRACT(MONTH FROM date) AS month,
  SUM(revenue) AS revenue,
  SUM(cost) AS cost
FROM (
  SELECT date, SUM(cost) AS cost, 0 AS revenue
  FROM `data-analytics-mate.DA.paid_search_cost`
  GROUP BY date

  UNION ALL

  SELECT s.date, 0 AS cost,
    SUM(p.price) AS revenue
  FROM `data-analytics-mate.DA.order` o
  JOIN `data-analytics-mate.DA.product` p
    ON o.item_id = p.item_id
  JOIN `data-analytics-mate.DA.session` s
    ON o.ga_session_id = s.ga_session_id
  GROUP BY s.date
)
GROUP BY year, month
ORDER BY year, month;
```

---

## Key Techniques

| Technique | Usage |
|---|---|
| `EXTRACT(YEAR/MONTH FROM date)` | Extracts year and month from date |
| `UNION ALL` | Combines cost and revenue rows into one dataset |
| `SUM()` with `0` placeholder | Fills missing values before aggregation |
| Subquery | Wraps combined data for outer aggregation |
| `JOIN` | Links orders to products and sessions |

---

## Output Format

| Column | Description |
|---|---|
| `year` | Year extracted from date |
| `month` | Month extracted from date |
| `revenue` | Total revenue for the period |
| `cost` | Total paid search cost for the period |

---

## Tools

![BigQuery](https://img.shields.io/badge/Google_BigQuery-4285F4?style=flat&logo=googlebigquery&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Datetime_Functions-informational?style=flat)
