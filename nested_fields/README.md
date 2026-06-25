# 📊 SQL Advanced: Nested Fields in BigQuery

## Task Description

Analyze YouTube page view events by continent using nested fields (ARRAY) in BigQuery.

**Requirements:**
- Unnest event parameters to access nested data
- Count total events and YouTube-related events per continent
- Calculate the percentage of YouTube events from total events per continent

---

## Dataset

**Source:** `data-analytics-mate.DA` (Google BigQuery)

**Tables used:**

| Table | Description |
|---|---|
| `event_params` | Event data with nested ARRAY of parameters |
| `session_params` | Session parameters including continent |

---

## Solution

```sql
SELECT
  sp.continent,
  COUNT(*) AS total_events,
  SUM(CASE WHEN LOWER(ep.value.string_value) LIKE '%youtube%' THEN 1 ELSE 0 END) AS youtube_events,
  ROUND(SUM(CASE WHEN LOWER(ep.value.string_value) LIKE '%youtube%' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS youtube_percentage
FROM `data-analytics-mate.DA.event_params` p
JOIN `data-analytics-mate.DA.session_params` sp
  ON p.ga_session_id = sp.ga_session_id
CROSS JOIN UNNEST(p.event_params) AS ep
WHERE ep.key = 'page_title' AND sp.continent != '(not set)'
GROUP BY sp.continent
ORDER BY sp.continent;
```

---

## Key Techniques

| Technique | Usage |
|---|---|
| `CROSS JOIN UNNEST(...)` | Flattens nested ARRAY field into rows |
| `LIKE '%youtube%'` | Filters YouTube-related page titles |
| `LOWER()` | Case-insensitive string matching |
| `SUM(CASE WHEN ...)` | Conditional counting of YouTube events |
| `WHERE continent != '(not set)'` | Filters out unresolved geodata |

---

## Output Format

| Column | Description |
|---|---|
| `continent` | Continent name |
| `total_events` | Total page view events from this continent |
| `youtube_events` | YouTube-related page view events |
| `youtube_percentage` | Share of YouTube events from total (%) |

---

## Tools

![BigQuery](https://img.shields.io/badge/Google_BigQuery-4285F4?style=flat&logo=googlebigquery&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Nested_Fields-informational?style=flat)
