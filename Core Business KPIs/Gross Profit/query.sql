-- Gross Profit: 
-- Difference between total sales revenue and product cost, reflecting operational profitability.
-- It's a precalculated measure in the fact 

SELECT 
    SUM(profit_amount) AS total_gross_profit
FROM Fact_Order_Line;
