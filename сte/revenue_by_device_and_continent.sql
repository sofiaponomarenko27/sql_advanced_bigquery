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

