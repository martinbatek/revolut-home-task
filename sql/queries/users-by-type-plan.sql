WITH user_groups AS (
    SELECT
        user_id,
        CASE
            WHEN user_type = 'PERSONAL' THEN 'RETAIL'
            WHEN user_type IN (
                'BUSINESS',
                'BUSINESS_EMPLOYEE',
                'BUSINESS_USER'
            ) THEN 'BUSINESS'
            WHEN user_type = 'YOUTH' THEN 'YOUTH'
            WHEN user_type = 'COMPANY' THEN 'COMPANY'
            ELSE NULL
        END AS user_group,
        user_plan
    FROM user_data
)
SELECT
    user_group,
    user_plan,
    COUNT(DISTINCT user_id) AS user_count
FROM user_groups
GROUP BY user_group, user_plan
ORDER BY user_group, user_plan