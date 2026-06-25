SELECT
EXTRACT(YEAR FROM date) AS year,
EXTRACT(MONTH FROM date) AS month,
SUM(revenue) AS revenue,
SUM(cost) AS cost
FROM (SELECT date, SUM(cost) AS cost, 0 AS revenue
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

