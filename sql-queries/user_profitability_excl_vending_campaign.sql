SELECT
    user_plan,
    SUM(amount_gbp)*1000 as gross_profit,
    COUNT(DISTINCT user_id) as users
   
FROM user_monthly_gp
WHERE user_id not in (
    SELECT DISTINCT
        user_id
    FROM user_monthly_gp
    where account_level_4='Vending Machine Rewards'
)
and user_type IN ('PERSONAL', 'YOUTH')
 GROUP BY user_plan