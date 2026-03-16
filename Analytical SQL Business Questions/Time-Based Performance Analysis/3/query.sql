-- Measure Year-to-Date profit to assess annual performance progression.

WITH daily_profit AS (
    SELECT 
        d.full_date,
        d.year,
        SUM(f.profit_amount) AS daily_profit
    FROM Fact_Order_Line f
    JOIN Dim_Date d ON f.date_key = d.date_key
    GROUP BY d.full_date, d.year
)
SELECT 
    full_date,
    year,
    daily_profit,
    SUM(daily_profit) OVER (PARTITION BY year ORDER BY full_date) AS year_to_date_profit
FROM daily_profit
ORDER BY full_date;
