with CustomerTotalSpend as (
    select customer_key, sum(net_amount) as total_spent
        from fact_order_line
        group by  customer_key
)

select customer_key , total_spent , 
        NTile(4) over (order by total_spent) as spending_quartile
from CustomerTotalSpend
order by total_spent desc;