SELECT
    user_id,
    is_nap,
    user_state,
    user_type,
    user_plan,
    user_country,
    onboarded_date,
    gp_total,
    vending_machine_rewards,
    gp_total - vending_machine_rewards AS gp_total_excluding_rewards
FROM user_data
WHERE ABS(vending_machine_rewards) > 0