SELECT
    pnl_month,
    user_country,
    user_plan,
    SUM(CASE WHEN account_level_4 = 'Interest' THEN amount_gbp ELSE 0 END)*1000 as loan_interest,
    SUM(CASE WHEN account_level_4 = 'Provisions' THEN amount_gbp ELSE 0 END)*1000 as provisions,
    COUNT(DISTINCT user_id) as loan_users
FROM user_monthly_gp
WHERE account_level_3 = 'Loans'
GROUP BY
    pnl_month,
    user_country,
    user_plan