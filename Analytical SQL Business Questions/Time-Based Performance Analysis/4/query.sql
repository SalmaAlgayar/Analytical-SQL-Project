-- Smooth short-term volatility using moving average trend analysis. 

WITH daily_revenue AS (
    SELECT 
        d.full_date,
        SUM(f.net_amount) AS daily_revenue
    FROM Fact_Order_Line f
    JOIN Dim_Date d ON f.date_key = d.date_key
    GROUP BY d.full_date
)
SELECT 
    full_date,
    daily_revenue,
    AVG(daily_revenue) OVER (ORDER BY full_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg_7day
FROM daily_revenue
ORDER BY full_date;
