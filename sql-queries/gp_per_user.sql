CREATE TABLE gp_per_user AS
WITH step1 AS
(
    SELECT
        user_country,
        user_type,
        user_plan,
        user_state,
        age_group,
        strftime('%Y-%m-01',onboarded_date) AS onboarded_month,
        is_nap,
        amount_gbp*1000 as amount_gbp,
        user_id
    FROM user_monthly_gp
),
step2 AS
(
    SELECT
        user_id,
        user_country,
        user_type,
        user_plan,
        user_state,
        age_group,
        onboarded_month,
        is_nap,
        SUM(amount_gbp) AS gross_profit
    FROM step1
    GROUP BY
        user_id,
        user_country,
        user_type,
        user_plan,
        user_state,
        age_group,
        onboarded_month,
        is_nap
    ORDER BY gross_profit DESC
),
vending_machine_campaign AS
(
    SELECT
        user_id,
        SUM(amount_gbp)*1000 AS vending_machine_reward
    FROM user_monthly_gp
    WHERE account_level_4 = 'Vending Machine Rewards'
    GROUP BY user_id
)
SELECT
    a.*,
    b.user_id IS NOT NULL AS vending_machine_tag,
    COALESCE(b.vending_machine_reward, 0) as vending_machine_reward,
    ntile(10) OVER(ORDER BY a.gross_profit) as gp_decile,
    ntile(10) OVER(PARTITION BY a.user_type ORDER BY a.gross_profit) as gp_decile_user_type
FROM step2 AS a
LEFT JOIN vending_machine_campaign AS b
    ON a.user_id = b.user_id
ORDER BY gross_profit DESC