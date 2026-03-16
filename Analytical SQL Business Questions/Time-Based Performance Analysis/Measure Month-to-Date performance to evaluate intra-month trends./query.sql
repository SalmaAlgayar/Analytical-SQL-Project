-- Measure Month-to-Date performance to evaluate intra-month trends

WITH daily_revenue AS (
    SELECT 
        d.full_date,
        d.year,
        d.month_name,
        d.day,
        SUM(f.net_amount) AS daily_revenue
    FROM Fact_Order_Line f
    JOIN Dim_Date d ON f.date_key = d.date_key
    GROUP BY d.full_date, d.year, d.month_name, d.day
)
SELECT 
    full_date,
    year,
    month_name,
    day,
    daily_revenue,
    SUM(daily_revenue) OVER (PARTITION BY year, month_name ORDER BY full_date) AS month_to_date_revenue
FROM daily_revenue
ORDER BY full_date;
