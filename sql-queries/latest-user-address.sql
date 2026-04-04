CREATE TABLE latest_user_address AS
WITH step1 AS
(
    SELECT
        user_id,
        user_city,
        user_country,
        ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY pnl_date DESC) AS rn
    FROM user_monthly_gp
)
SELECT
    user_id,
    user_city,
    user_country
FROM step1
WHERE rn=1