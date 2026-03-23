SELECT 
    c.category_name,
    p.product_name,
    SUM(f.net_amount) AS product_revenue,
    ROUND(
        SUM(f.net_amount) /
        SUM(SUM(f.net_amount)) OVER (PARTITION BY c.category_name) * 100,
        2
    ) AS contribution_pct
FROM Fact_Order_Line f
JOIN Dim_Product p 
    ON f.product_key = p.product_key
JOIN Dim_Category c 
    ON f.category_key = c.category_key
GROUP BY c.category_name, p.product_name;