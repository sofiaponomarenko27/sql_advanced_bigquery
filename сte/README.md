# 📊 SQL Advanced: CTEs in BigQuery

## Task Description

Analyze revenue, accounts, and sessions by continent and device type using **Common Table Expressions (CTEs)**.

**Requirements:**
- Calculate total revenue, revenue from mobile and desktop per continent
- Calculate % of continent revenue from total revenue
- Count total and verified accounts per continent
- Count sessions per continent

---

## Dataset

**Source:** `data-analytics-mate.DA` (Google BigQuery)

**Tables used:**

| Table | Description |
|---|---|
| `product` | Product data with prices |
| `order` | Order log linked to sessions |
| `session` | Session data |
| `session_params` | Session parameters including device and continent |
| `account_session` | Mapping between accounts and sessions |
| `account` | Account data with verification status |

---

## Solution

```sql
WITH revenue_by_continent AS (
  SELECT
    sp.continent,
    SUM(pr.price) AS revenue,
    SUM(CASE WHEN sp.device = 'mobile' THEN pr.price ELSE 0 END) AS revenue_mobile,
    SUM(CASE WHEN sp.device = 'desktop' THEN pr.price ELSE 0 END) AS revenue_desktop
  FROM `data-analytics-mate.DA.product` pr
  LEFT JOIN `data-analytics-mate.DA.order` o ON pr.item_id = o.item_id
  INNER JOIN `data-analytics-mate.DA.session` s ON s.ga_session_id = o.ga_session_id
  INNER JOIN `data-analytics-mate.DA.session_params` sp ON s.ga_session_id = sp.ga_session_id
  WHERE sp.continent != '(not set)'
  GROUP BY sp.continent
),

accounts_by_continent AS (
  SELECT
    sp.continent,
    COUNT(DISTINCT a.id) AS account_count,
    COUNT(DISTINCT CASE WHEN a.is_verified = 1 THEN a.id END) AS verified_account
  FROM `data-analytics-mate.DA.session_params` sp
  JOIN `data-analytics-mate.DA.account_session` acs ON sp.ga_session_id = acs.ga_session_id
  JOIN `data-analytics-mate.DA.account` a ON acs.account_id = a.id
  WHERE sp.continent != '(not set)'
  GROUP BY sp.continent
),

sessions_by_continent AS (
  SELECT
    sp.continent,
    COUNT(DISTINCT s.ga_session_id) AS session_count
  FROM `data-analytics-mate.DA.session` s
  JOIN `data-analytics-mate.DA.session_params` sp ON s.ga_session_id = sp.ga_session_id
  WHERE sp.continent != '(not set)'
  GROUP BY sp.continent
)

SELECT
  r.continent AS Continent,
  r.revenue AS Revenue,
  r.revenue_mobile AS `Revenue from Mobile`,
  r.revenue_desktop AS `Revenue from Desktop`,
  (r.revenue / SUM(r.revenue) OVER ()) * 100 AS `% Revenue from Total`,
  a.account_count AS `Account Count`,
  a.verified_account AS `Verified Account`,
  s.session_count AS `Session Count`
FROM revenue_by_continent r
JOIN accounts_by_continent a ON r.continent = a.continent
JOIN sessions_by_continent s ON r.continent = s.continent
ORDER BY r.revenue DESC;
```

---

## Key Techniques

| Technique | Usage |
|---|---|
| `WITH ... AS ()` (CTE) | Splits complex query into 3 readable, reusable blocks |
| `SUM(CASE WHEN ...)` | Pivot-style aggregation by device type |
| `SUM() OVER ()` | Calculates % of total revenue using window function |
| `COUNT(DISTINCT ... CASE WHEN ...)` | Counts verified accounts conditionally |
| `LEFT JOIN` vs `INNER JOIN` | Intentional join type selection based on data logic |
| `WHERE continent != '(not set)'` | Filters out unresolved geodata |

---

## Output Format

| Column | Description |
|---|---|
| `Continent` | Continent name |
| `Revenue` | Total revenue from this continent |
| `Revenue from Mobile` | Revenue from mobile devices |
| `Revenue from Desktop` | Revenue from desktop devices |
| `% Revenue from Total` | Share of this continent's revenue in overall total |
| `Account Count` | Total accounts from this continent |
| `Verified Account` | Verified accounts from this continent |
| `Session Count` | Total sessions from this continent |

---

## Tools

![BigQuery](https://img.shields.io/badge/Google_BigQuery-4285F4?style=flat&logo=googlebigquery&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-CTEs-informational?style=flat)
