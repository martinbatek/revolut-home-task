-- SQLite
SELECT
    user_type,
    COUNT(DISTINCT user_id) AS users
FROM user_monthly_gp
GROUP BY user_type
