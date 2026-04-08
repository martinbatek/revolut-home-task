SELECT
    account_level_1,
    account_level_2,
    account_level_3,
    account_level_4,
    user_country,
    user_type,
    user_plan,
    SUM(amount_gbp) AS gross_profit
FROM user_monthly_gp
GROUP BY account_level_1,
    account_level_2,
    account_level_3,
    account_level_4,
    user_country,
    user_type,
    user_plan