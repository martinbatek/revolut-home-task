SELECT
    pnl_month,
    count(*) as entries
from user_monthly_gp
group by pnl_month
order by pnl_month