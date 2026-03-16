-- Identify acceleration or deceleration in revenue dynamics.

WITH monthly_revenue AS (
    SELECT 
        d.year,
        d.month_name,
        MIN(d.full_date) AS month_start,
        SUM(f.net_amount) AS monthly_revenue
    FROM Fact_Order_Line f
    JOIN Dim_Date d ON f.date_key = d.date_key
    GROUP BY d.year, d.month_name
),
monthly_with_lag AS (
    SELECT 
        year,
        month_name,
        month_start,
        monthly_revenue,
        LAG(monthly_revenue) OVER (ORDER BY year, month_start) AS prev_month_revenue,
        monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY year, month_start) AS change
    FROM monthly_revenue
)
SELECT 
    year,
    month_name,
    monthly_revenue,
    prev_month_revenue,
    change,
    LAG(change) OVER (ORDER BY year, month_start) AS prev_change,
    change - LAG(change) OVER (ORDER BY year, month_start) AS acceleration
FROM monthly_with_lag
ORDER BY year, month_start;
