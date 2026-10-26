with user_tags as
(
    SELECT
        user_id,
        user_country,
        user_type,
        user_plan,
        user_state,
        is_nap,
        vending_machine_tag,
        gp_decile,
        gp_decile_user_type
    FROM gp_per_user
)
SELECT
    b.account_level_1,
    b.account_level_2,
    b.account_level_3,
    b.account_level_4,
    a.user_country,
    a.user_type,
    a.user_plan,
    a.user_state,
    a.is_nap,
    a.vending_machine_tag,
    a.gp_decile,
    a.gp_decile_user_type,
    SUM(b.amount_gbp)*1000 AS gross_profit,
    COUNT(*) AS entries
FROM user_monthly_gp AS b
LEFT JOIN user_tags AS a
    ON a.user_id = b.user_id
GROUP BY b.account_level_1,
    b.account_level_2,
    b.account_level_3,
    b.account_level_4,
    a.user_country,
    a.user_type,
    a.user_plan,
    a.user_state,
    a.is_nap,
    a.vending_machine_tag,
    a.gp_decile,
    a.gp_decile_user_type