SELECT
    account_level_1,
    account_level_2,
    account_level_3,
    account_level_4,
    revenue_expense,
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
FROM case_study_data
GROUP BY 
    account_level_1,
    account_level_2,
    account_level_3,
    account_level_4,
    revenue_expense