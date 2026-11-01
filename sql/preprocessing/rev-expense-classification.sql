WITH step1 AS (
    SELECT
        account_level_1,
        account_level_2,
        account_level_3,
        account_level_4,
        SUM(
            CASE
                WHEN amount_gbp >=0 THEN 1
                ELSE 0
            END
        ) AS count_of_revenues,
        SUM(
            CASE
                WHEN amount_gbp <0 THEN 1
                ELSE 0
            END
        ) AS count_of_costs
    FROM data
    GROUP BY 
        account_level_1,
        account_level_2,
        account_level_3,
        account_level_4
)
SELECT
    account_level_1,
    account_level_2,
    account_level_3,
    account_level_4,
    CASE
        WHEN
            UPPER(COALESCE(account_level_1,'')) LIKE '%FEE%'
            OR UPPER(COALESCE(account_level_2,'')) LIKE '%FEE%'
            OR UPPER(COALESCE(account_level_3,'')) LIKE '%FEE%'
            OR UPPER(COALESCE(account_level_4,'')) LIKE '%FEE%'
        THEN 'revenue'
        WHEN
            UPPER(COALESCE(account_level_1,'')) LIKE '%CHARGE%'
            OR UPPER(COALESCE(account_level_2,'')) LIKE '%CHARGE%'
            OR UPPER(COALESCE(account_level_3,'')) LIKE '%CHARGE%'
            OR UPPER(COALESCE(account_level_4,'')) LIKE '%CHARGE%'
        THEN 'expense'
        ELSE
            CASE
                WHEN count_of_revenues > count_of_costs THEN 'revenue'
                WHEN count_of_revenues < count_of_costs THEN 'expense'
                ELSE NULL
            END
    END AS revenue_expense
FROM step1
ORDER BY 
    account_level_1,
    account_level_2,
    account_level_3,
    account_level_4