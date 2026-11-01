WITH step1 AS (
    SELECT
        user_id,
        is_nap,
        user_type,
        user_plan,
        gp_total,
        vending_machine_rewards,
        gp_total - vending_machine_rewards AS gp_total_excluding_rewards
    FROM user_data
    WHERE ABS(vending_machine_rewards) > 0
)
SELECT
    *,
    PERCENT_RANK() OVER(PARTITION BY is_nap ORDER BY vending_machine_rewards DESC) AS vmr_perc_rank,
    NTILE(10) OVER(PARTITION BY is_nap ORDER BY vending_machine_rewards DESC) AS vmr_decile
FROM step1;