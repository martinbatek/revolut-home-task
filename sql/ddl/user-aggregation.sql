DROP TABLE IF EXISTS user_data;
CREATE TABLE user_data AS
WITH user_nap AS (
    WITH step1 AS (
        SELECT
            user_id,
            is_nap,
            ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY pnl_date DESC) AS rn
        FROM case_study_data
    )
    SELECT
        user_id,
        is_nap -- latest is_nap status
    FROM step1
    WHERE rn=1
),
onboarded_dates AS (
    WITH step1 AS (
        SELECT user_id,
            onboarded_date,
            user_state,
            ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY pnl_date DESC) as rn
        FROM case_study_data
    )
    SELECT
        user_id,
        user_state,
        DATE(onboarded_date) AS onboarded_date
    FROM step1
    WHERE rn=1
),
plan_info AS (
    WITH step1 AS (
        SELECT
            user_id,
            user_type,
            user_plan,
            max(pnl_date) AS latest_date 
        FROM case_study_data
        GROUP BY 
            user_id,
            user_type,
            user_plan
    ),
    step2 AS (
        SELECT
            user_id,
            user_type,
            user_plan,
            ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY latest_date DESC) as rn
        FROM step1
    ),
    current_plans AS (
        SELECT
            user_id,
            user_type,
            user_plan
        FROM step2
        WHERE rn=1
    ),
    previous_plans AS (
        SELECT
            user_id,
            user_type AS prev_user_type,
            user_plan AS prev_user_plan
        FROM step2
        WHERE rn=2
    )
    SELECT
        c.user_id,
        c.user_type,
        c.user_plan,
        p.prev_user_type,
        p.prev_user_plan
    FROM current_plans as c
    LEFT JOIN previous_plans AS p
        ON c.user_id = p.user_id
),
geography AS (
    with geos_ranked AS (
        SELECT
            user_id,
            user_country,
            user_city,
            ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY pnl_date DESC) AS rn
        FROM case_study_data
    )
    SELECT
        user_id,
        user_country,
        user_city
    FROM geos_ranked
    WHERE rn=1
),
profitability AS (
    SELECT
        user_id,
        SUM(amount_gbp) AS gp_total,
        SUM(
            CASE
                WHEN revenue_expense = 'revenue'
                    THEN amount_gbp
                    ELSE 0.0
            END
        ) AS revenue,
        SUM(
            CASE
                WHEN revenue_expense = 'expense'
                    THEN amount_gbp
                    ELSE 0.0
            END
        ) AS expense,
        SUM(
            CASE 
                WHEN account_level_4 = 'Vending Machine Rewards' 
                    THEN amount_gbp 
                    ELSE 0.0 
            END
        ) AS vending_machine_rewards,
        SUM(
            CASE
                WHEN account_level_3 = 'Top-ups'
                    THEN amount_gbp
                    ELSE 0.0
            END
        ) AS top_ups,
        SUM(
            CASE
                WHEN account_level_2 = 'Subscriptions'
                    THEN amount_gbp
                    ELSE 0.0
            END
        ) AS subscriptions,
        SUM(
            CASE
                WHEN account_level_2 = 'Lifestyle'
                    THEN amount_gbp
                    ELSE 0.0
            END
        ) AS lifestyle,
        SUM(
            CASE
                WHEN account_level_2 = 'FX'
                    THEN amount_gbp
                    ELSE 0.0
            END
        ) AS fx,
        SUM(
            CASE
                WHEN account_level_2 = 'Interest Income'
                    THEN amount_gbp
                    ELSE 0.0
            END
        ) AS interest_income,
        SUM(
            CASE
                WHEN account_level_3 = 'Interchange Fees'
                    THEN amount_gbp
                    ELSE 0.0
            END
        ) AS interchange_fees,
        SUM(
            CASE
                WHEN account_level_3 = 'atm'
                    THEN amount_gbp
                    ELSE 0.0
            END
        ) AS atm
    FROM case_study_data
    GROUP BY user_id
)
SELECT
    u.user_id,
    u.is_nap,
    o.onboarded_date,
    o.user_state,
    p.user_type,
    p.user_plan,
    p.prev_user_type,
    p.prev_user_plan,
    g.user_country,
    g.user_city,
    pr.gp_total,
    pr.revenue,
    pr.expense,
    pr.vending_machine_rewards,
    pr.top_ups,
    pr.subscriptions,
    pr.lifestyle,
    pr.fx,
    pr.interest_income,
    pr.interchange_fees,
    pr.atm
FROM user_nap AS u
LEFT JOIN onboarded_dates AS o
    ON u.user_id = o.user_id
LEFT JOIN plan_info AS p
    ON u.user_id = p.user_id
LEFT JOIN geography AS g
    ON u.user_id = g.user_id
LEFT JOIN profitability AS pr
    ON u.user_id = pr.user_id
;