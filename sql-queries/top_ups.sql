-- SQLite
SELECT
    account_level_4 AS top_up_partner,
    count(*) as top_ups,
    SUM(amount_gbp)*1000 as top_up_cost,
    count(distinct user_id) as top_up_users
FROM user_monthly_gp
WHERE account_level_3 = 'Top-ups'
AND account_level_4 <> 'Top-Up Surcharge Fee'
GROUP BY account_level_4