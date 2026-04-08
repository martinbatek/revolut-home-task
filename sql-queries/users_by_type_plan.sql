-- SQLite
SELECT
    user_type,
    user_plan,
    COUNT(DISTINCT user_id) users
FROM user_monthly_gp
GROUP BY user_type, user_plan