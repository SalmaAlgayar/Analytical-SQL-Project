-- Revenue: 
--Total monetary value generated from completed sales transactions over a defined period. 
-- We chose a period from '2022-11-04' to '2022-11-09

SELECT 
    SUM(f.unit_price * f.quantity) AS total_revenue
FROM Fact_Order_Line f
JOIN Dim_Date d ON f.date_key = d.date_key
WHERE d.full_date BETWEEN DATE '2022-11-04' AND DATE '2022-11-09';
