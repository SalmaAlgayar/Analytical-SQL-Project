select f.customer_key 
        , d.full_date 
        , f.net_amount 
        , sum(net_amount) over (partition by customer_key order by d.full_date) as cumulative_spending
from 
        fact_order_line f inner join dim_date d 
        on f.date_key = d.date_key
order by f.customer_key, d.full_date;