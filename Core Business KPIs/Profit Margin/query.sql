with calculations as (
    select 
        sum(profit_amount) as Total_Net_Profit,
        sum(net_amount) as Total_Net_Revenue
    from fact_order_line
)

select Total_Net_Profit , Total_Net_Revenue,
        round( (Total_Net_Profit / Total_Net_Revenue) ,2)* 100 as Profit_Margin_Percentage
from calculations;