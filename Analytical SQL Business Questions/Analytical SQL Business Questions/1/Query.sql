SELECT
    c.category_name,
    p.product_name,
    SUM(f.net_amount) AS revenue,
    RANK()
    OVER(PARTITION BY c.category_name
         ORDER BY
             SUM(f.net_amount) DESC
    )                 AS product_rank
FROM
         fact_order_line f
    JOIN dim_product  p ON f.product_key = p.product_key
    JOIN dim_category c ON f.category_key = c.category_key
GROUP BY
    c.category_name,
    p.product_name;