SELECT 
    c.region,
    SUM(f.profit_amount) AS total_profit,
    RANK() OVER (
        ORDER BY SUM(f.profit_amount) DESC
    ) AS region_rank
FROM Fact_Order_Line f
JOIN Dim_Customer c 
    ON f.customer_key = c.customer_key
GROUP BY c.region;