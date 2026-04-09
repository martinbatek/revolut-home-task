with user_tags as
(
    SELECT
        user_id,
        MAX(vending_machine_tag) AS vending_machine_tag,
        MAX(gp_decile) AS gp_decile,
        MAX(gp_decile_user_type) AS gp_decile_user_type
    FROM gp_per_user
    GROUP BY user_id
)
SELECT
    a.account_level_1,
    a.account_level_2,
    a.account_level_3,
    a.account_level_4,
    a.user_country,
    a.user_type,
    a.user_plan,
    a.user_state,
    a.is_nap,
    b.vending_machine_tag,
    b.gp_decile,
    b.gp_decile_user_type,
    SUM(a.amount_gbp)*1000 AS gross_profit,
    COUNT(*) AS entries
FROM user_monthly_gp AS a
LEFT JOIN user_tags AS b
    ON a.user_id = b.user_id
GROUP BY a.account_level_1,
    a.account_level_2,
    a.account_level_3,
    a.account_level_4,
    a.user_country,
    a.user_type,
    a.user_plan,
    a.user_state,
    a.is_nap,
    b.vending_machine_tag,
    b.gp_decile,
    b.gp_decile_user_type