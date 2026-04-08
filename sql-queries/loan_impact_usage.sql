-- SQLite
with active_users AS
(
    SELECT
        user_country,
        age_group,
        user_plan,
        COUNT(distinct user_id) as active_users
    FROM user_monthly_gp
    WHERE user_state ='Active'
    AND user_type='PERSONAL'
    GROUP BY 
        user_country,
        age_group,
        user_plan
),
loan_users AS
(
    SELECT
        user_country,
        age_group,
        user_plan,
        COUNT(DISTINCT user_id) AS loan_users
    FROM user_monthly_gp
    WHERE account_level_3='Loans'
    AND user_state='Active'
    AND user_type='PERSONAL'
    GROUP BY
        user_country,
        age_group,
        user_plan
)
SELECT
    a.user_country,
    a.age_group,
    a.user_plan,
    a.active_users,
    COALESCE(b.loan_users,0) as loan_users
FROM active_users AS a
LEFT JOIN loan_users AS b
    ON a.user_country = b.user_country
    AND a.age_group = b.age_group
    AND a.user_plan = b.user_plan