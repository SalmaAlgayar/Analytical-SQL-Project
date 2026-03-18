-- Detect trending categories based on recent performance compared to historical behavior. 
-- we put 2023 sales and 2022 sales side-by-side for each category

SELECT 
    c.category_name,
    SUM(CASE WHEN d.year = 2023 THEN f.net_amount ELSE 0 END) AS recent_revenue,
    SUM(CASE WHEN d.year = 2022 THEN f.net_amount ELSE 0 END) AS historical_revenue,
    CASE 
        WHEN SUM(CASE WHEN d.year = 2023 THEN f.net_amount ELSE 0 END) >
             SUM(CASE WHEN d.year = 2022 THEN f.net_amount ELSE 0 END)
        THEN '2023'
        ELSE '2022'
    END AS winner_year
FROM Fact_Order_Line f
JOIN Dim_Category c ON f.category_key = c.category_key
JOIN Dim_Date d ON f.date_key = d.date_key
GROUP BY c.category_name;