-- Relative increase or decrease in revenue compared to a previous time period. (did we make more money this year compared to last year?)

SELECT 
    d.year,
    SUM(f.net_amount) AS current_revenue,
    LAG(SUM(f.net_amount)) OVER(ORDER BY d.year) AS last_year_revenue 
FROM Fact_Order_Line f
JOIN Dim_Date d ON f.date_key = d.date_key
GROUP BY d.year;