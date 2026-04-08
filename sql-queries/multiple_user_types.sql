-- Check that each user_id corresponds to only one user type
WITH step1 AS
(
    SELECT 
        user_id, 
        COUNT(DISTINCT user_type) AS user_types 
    FROM user_monthly_gp
    GROUP BY user_id
),
filtered AS (
    SELECT DISTINCT 
        user_id,
        user_type
    FROM user_monthly_gp
    WHERE user_id IN (SELECT user_id FROM step1 WHERE user_types > 1)
),
pivoted AS (
SELECT 
    user_id,
    MAX(CASE WHEN user_type = 'PERSONAL' THEN TRUE ELSE FALSE END) AS `PERSONAL`,
    MAX(CASE WHEN user_type = 'BUSINESS' THEN TRUE ELSE FALSE END) AS `BUSINESS`,
    MAX(CASE WHEN user_type = 'COMPANY' THEN TRUE ELSE FALSE END) AS `COMPANY`,
    MAX(CASE WHEN user_type = 'YOUTH' THEN TRUE ELSE FALSE END) AS `YOUTH`
FROM filtered
GROUP BY user_id
ORDER BY user_id
)
SELECT
    `PERSONAL`,
    `BUSINESS`,
    `COMPANY`,
    `YOUTH`,
    COUNT(user_id) AS users
FROM pivoted
GROUP BY
    `PERSONAL`,
    `BUSINESS`,
    `COMPANY`,
    `YOUTH`