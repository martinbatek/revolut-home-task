-- SQLite
SELECT
    user_country,
    COUNT(DISTINCT user_id) users
FROM user_monthly_gp
GROUP BY user_country
ORDER BY users DESC