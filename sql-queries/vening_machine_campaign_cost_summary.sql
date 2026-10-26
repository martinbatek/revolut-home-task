-- SQLite
SELECT
    user_type,
    user_plan,
    user_country,
    age_group,
    user_state,
    is_nap,
    SUM(amount_gbp) as campaign_cost,
    count(distinct user_id) as campaign_users
FROM user_monthly_gp
where account_level_4='Vending Machine Rewards'
group by
 user_type,
    user_plan,
    user_country,
    age_group,
    user_state,
    is_nap
