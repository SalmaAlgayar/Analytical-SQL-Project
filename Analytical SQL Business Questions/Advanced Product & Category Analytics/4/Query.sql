-- Evaluate profit consistency across time periods. 
-- list the profit of each month in each year.

SELECT 
    d.year,
    d.month_name,
    SUM(f.profit_amount) AS total_monthly_profit
FROM Fact_Order_Line f
JOIN Dim_Date d ON f.date_key = d.date_key
GROUP BY d.year, d.month_name