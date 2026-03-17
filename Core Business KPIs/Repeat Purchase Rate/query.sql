with CustomerOrderSummary AS (
    select customer_key, 
    count(distinct order_id ) as total_orders,
    min(date_key) as first_purchase_order
    from fact_order_line
    group by customer_key
),
RepeatCustomerCounts as (
    select count(customer_key) as total_customers,
    count(distinct case when total_orders > 1 then customer_key end) as repeat_customers
    from CustomerOrderSummary
)

select repeat_customers , total_customers ,round(( repeat_customers / total_customers ),2) * 100 as repeat_rate_percentage
FROM RepeatCustomerCounts;