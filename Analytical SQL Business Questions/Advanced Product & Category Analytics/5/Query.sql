-- Identify products experiencing sustained decline across consecutive periods. 
-- this year < last year

WITH YearlySales AS (
    SELECT 
        p.product_name,
        d.year,
        SUM(f.net_amount) AS current_revenue,
        LAG(SUM(f.net_amount)) OVER(PARTITION BY p.product_name ORDER BY d.year) AS last_year_revenue
    FROM Fact_Order_Line f
    JOIN Dim_Product p ON f.product_key = p.product_key
    JOIN Dim_Date d ON f.date_key = d.date_key
    GROUP BY p.product_name, d.year
)
SELECT * 
FROM YearlySales
WHERE current_revenue < last_year_revenue;