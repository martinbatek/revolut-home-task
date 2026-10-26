-- SQLite
with campaign_users as
(
    SELECT
        user_id,
        user_plan,
        user_country,
        is_nap,
        SUM(amount_gbp)*1000 AS campaign_cost
    FROM user_monthly_gp
    where account_level_4='Vending Machine Rewards'
    group by user_id,
        user_plan,
        user_country,
        is_nap
)
SELECT
    a.user_plan,
    a.user_country,
    a.is_nap,
    a.campaign_cost,
    SUM(CASE WHEN b.account_level_4 <> 'Vending Machine Rewards' THEN amount_gbp*1000 ELSE 0 END) as user_gp,
    COUNT(DISTINCT a.user_id) as users
FROM campaign_users AS a
INNER JOIN user_monthly_gp AS b
    ON a.user_id = b.user_id
GROUP BY a.user_plan,
    a.user_country,
    a.is_nap,
    a.campaign_cost