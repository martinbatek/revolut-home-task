WITH step1 AS (
    SELECT
        user_id,
        top_ups,
        top_ups_fire,
        top_ups_ice,
        top_ups_rock,
        atm_revenue,
        atm_expense,
        bp_revenue,
        bp_expense,
        (top_ups != 0) AS top_ups_user,
        (atm_revenue !=0 OR atm_expense != 0) AS atm_user,
        (bp_revenue != 0 OR bp_expense != 0) AS bp_user
    FROM user_data
)
SELECT
    *
FROM step1
WHERE
    top_ups_user=1
    OR atm_user=1
    OR bp_user=1