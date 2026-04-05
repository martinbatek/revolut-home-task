WITH distinct_entries AS (
    SELECT DISTINCT
        user_id,
        age_group,
        user_country,
        user_type,
        ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY pnl_date DESC) AS rn
    FROM user_monthly_gp
)
SELECT
    age_group,
    user_country,
    user_type,
    COUNT(user_id) AS users
FROM distinct_entries
WHERE rn=1
GROUP BY
    age_group,
    user_country,
    user_type
