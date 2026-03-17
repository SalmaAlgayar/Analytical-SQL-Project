-- Highest 2% of customers 
with CustomerTotalSpend as (
    select customer_key, sum(net_amount) as total_spent
        from fact_order_line
        group by  customer_key
) 
, CalculatePercentile as (
    select customer_key , total_spent,
             percent_Rank() over (order by total_spent desc)  as top_percentile 
    from CustomerTotalSpend
)

select customer_key , total_spent , round(top_percentile * 100, 2) as top_percentile_value
from CalculatePercentile
where top_percentile <= 0.02;
        