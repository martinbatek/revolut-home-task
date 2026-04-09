-- GP per user summary
SELECT
    user_country,
    user_type,
    user_plan,
    user_state,
    age_group,
    onboarded_month,
    is_nap,
    vending_machine_tag,
    gp_decile,
    gp_decile_user_type,
    COUNT(distinct user_id) as users,
    SUM(gross_profit) as gross_profit,
    SUM(vending_machine_reward) as vending_machine_reward
FROM gp_per_user
GROUP BY
    user_country,
    user_type,
    user_plan,
    user_state,
    age_group,
    onboarded_month,
    is_nap,
    vending_machine_tag,
    gp_decile,
    gp_decile_user_type