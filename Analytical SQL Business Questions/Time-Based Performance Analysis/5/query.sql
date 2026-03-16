 -- Compare current month performance with previous month to detect growth or decline.

WITH monthly_revenue AS (
    SELECT 
        d.year,
        d.month_name,
        MIN(d.full_date) as month_start,
        SUM(f.net_amount) AS monthly_revenue
    FROM Fact_Order_Line f
    JOIN Dim_Date d ON f.date_key = d.date_key
    GROUP BY d.year, d.month_name
)
SELECT 
    year,
    month_name,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY year, month_start) AS previous_month_revenue,
    monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY year, month_start) AS month_over_month_change
FROM monthly_revenue
ORDER BY year, month_start;
