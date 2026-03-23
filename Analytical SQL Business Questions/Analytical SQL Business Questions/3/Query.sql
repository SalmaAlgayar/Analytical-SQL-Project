SELECT *
FROM (
    SELECT 
        p.product_name,
        SUM(f.net_amount) AS revenue,
        ROUND(
            SUM(SUM(f.net_amount)) OVER (ORDER BY SUM(f.net_amount) DESC) /
            SUM(SUM(f.net_amount)) OVER () * 100,
            2
        ) AS cumulative_pct
    FROM Fact_Order_Line f
    JOIN Dim_Product p 
        ON f.product_key = p.product_key
    GROUP BY p.product_name
)
WHERE cumulative_pct <= 80;