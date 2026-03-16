-- Produce cumulative revenue over time to understand long-term growth behavior

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
    SUM(daily_revenue) OVER (ORDER BY full_date) AS cumulative_revenue
FROM daily_revenue
ORDER BY full_date;
