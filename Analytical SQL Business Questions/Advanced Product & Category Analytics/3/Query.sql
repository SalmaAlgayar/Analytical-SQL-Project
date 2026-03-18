-- Analyze seasonality by comparing the same month across different years.
-- we wnt to look at the same month (july for example) for all years.

SELECT 
    d.month_name,
    d.year,
    SUM(f.net_amount) AS total_revenue
FROM Fact_Order_Line f
JOIN Dim_Date d ON f.date_key = d.date_key
GROUP BY d.month_name, d.year
ORDER BY TO_DATE(d.month_name, 'Month'), d.year;