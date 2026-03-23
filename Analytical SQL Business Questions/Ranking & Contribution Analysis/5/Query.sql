SELECT 
    c.category_name,
    p.brand,
    SUM(f.profit_amount) AS total_profit,
    RANK() OVER (
        PARTITION BY c.category_name
        ORDER BY SUM(f.profit_amount) DESC
    ) AS brand_rank
FROM Fact_Order_Line f
JOIN Dim_Product p 
    ON f.product_key = p.product_key
JOIN Dim_Category c 
    ON f.category_key = c.category_key
GROUP BY c.category_name, p.brand;