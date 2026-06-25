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


