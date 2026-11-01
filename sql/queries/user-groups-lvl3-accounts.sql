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
        END AS user_group
    FROM user_data
),
interactions AS (
    SELECT DISTINCT
        account_level_1,
        account_level_2,
        account_level_3,
        user_id
    FROM case_study_data
)
SELECT
    a.account_level_1,
    a.account_level_2,
    a.account_level_3,
    SUM(
        CASE
            WHEN b.user_group = 'RETAIL'
                THEN 1
                ELSE 0
        END
    ) AS retail_users,
    SUM(
        CASE
            WHEN b.user_group = 'BUSINESS'
                THEN 1
                ELSE 0
        END
    ) AS business_users,
    SUM(
        CASE
            WHEN b.user_group = 'YOUTH'
                THEN 1
                ELSE 0
        END
    ) AS youth_users,
    SUM(
        CASE
            WHEN b.user_group = 'COMPANY'
                THEN 1
                ELSE 0
        END
    ) AS company_users
FROM interactions AS a
LEFT JOIN user_groups AS b
    ON a.user_id = b.user_id
GROUP BY
    a.account_level_1,
    a.account_level_2,
    a.account_level_3
ORDER BY
    a.account_level_1,
    a.account_level_2,
    a.account_level_3;