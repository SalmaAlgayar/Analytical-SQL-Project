with CustomerOrderSummary AS (
    select f.customer_key, 
    f.order_id, 
    d.full_date,
    lag(d.full_date) over(partition by f.customer_key order by d.full_date) as previous_order_date
    from fact_order_line f join dim_date d 
    on f.date_key = d.date_key 
)
select customer_key , full_date , previous_order_date , 
        ( full_date  - previous_order_date ) as days_since_previous_order 
from CustomerOrderSummary
where previous_order_date is not null;