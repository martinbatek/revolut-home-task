-- SQLite
with active_users as
(
SELECT
    user_country,
    user_plan,
    count(distinct user_id) as active_users
FROM user_monthly_gp
WHERE user_state = 'Active'
AND user_type = 'PERSONAL'
group by user_country, user_plan
),
instant_access_savings as
(
SELECT
    user_country,
    user_plan,
    count(distinct user_id) as ias_users,
    sum(amount_gbp)*1000 as ias_gp
FROM user_monthly_gp
WHERE user_state = 'Active'
AND user_type = 'PERSONAL'
AND account_level_3='Instant Access'
group by user_country, user_plan
)
SELECT
    a.user_country,
    a.user_plan,
    a.active_users,
    COALESCE(b.ias_users,0) AS ias_users,
    COALESCE(b.ias_gp,0) AS ias_gp
FROM active_users AS a
LEFT JOIN instant_access_savings AS b
    ON a.user_country = b.user_country
    AND a.user_plan = b.user_plan
