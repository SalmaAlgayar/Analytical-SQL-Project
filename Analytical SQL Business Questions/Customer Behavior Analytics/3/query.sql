with CustomerLastOrder as(
    select f.customer_key , max(d.full_date) as last_order
    from 
        fact_order_line f inner join dim_date d
        on f.date_key = d.date_key
    group by f.customer_key
)

select customer_key , last_order
        , rank() over(order by last_order desc) as recency_rank
from 
        CustomerLastOrder;