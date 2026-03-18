-- Assess revenue volatility for each product.
-- (we using standard deviation(STDDEV). a high number means it's volatile and low number means it's stable)
SELECT 
    p.product_name,
    ROUND(STDDEV(f.net_amount)) AS revenue_volatility_score
FROM Fact_Order_Line f
JOIN Dim_Product p ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY revenue_volatility_score;