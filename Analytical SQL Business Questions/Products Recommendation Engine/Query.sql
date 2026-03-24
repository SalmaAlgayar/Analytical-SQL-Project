-- ============================================================
-- Set your product ID
-- ============================================================
DEFINE input_pid = 'PROD-003'

SET SERVEROUTPUT ON;

DECLARE
    v_count NUMBER;
BEGIN
    SELECT
        COUNT(*)
    INTO v_count
    FROM
        dim_product
    WHERE
        product_id = '&input_pid';

    dbms_output.put_line('Products found: ' || v_count);
    SELECT
        COUNT(*)
    INTO v_count
    FROM
             fact_order_line f
        JOIN dim_product dp ON f.product_key = dp.product_key
    WHERE
        dp.product_id = '&input_pid';

    dbms_output.put_line('Fact rows: ' || v_count);
    SELECT
        COUNT(DISTINCT f.order_id)
    INTO v_count
    FROM
             fact_order_line f
        JOIN dim_product dp ON f.product_key = dp.product_key
    WHERE
        dp.product_id = '&input_pid';

    dbms_output.put_line('Distinct order_ids: ' || v_count);
    SELECT
        COUNT(DISTINCT f2.order_id)
    INTO v_count
    FROM
             fact_order_line f1
        JOIN dim_product     dp ON f1.product_key = dp.product_key
        JOIN fact_order_line f2 ON f1.order_id = f2.order_id
                                   AND f2.product_key != f1.product_key
    WHERE
        dp.product_id = '&input_pid';

    dbms_output.put_line('Order_ids shared with other products: ' || v_count);
    SELECT
        COUNT(DISTINCT f1.customer_key)
    INTO v_count
    FROM
             fact_order_line f1
        JOIN dim_product dp ON f1.product_key = dp.product_key
    WHERE
        dp.product_id = '&input_pid';

    dbms_output.put_line('Distinct customers who bought it: ' || v_count);
    SELECT
        COUNT(DISTINCT f2.product_key)
    INTO v_count
    FROM
             fact_order_line f1
        JOIN dim_product     dp ON f1.product_key = dp.product_key
        JOIN fact_order_line f2 ON f1.customer_key = f2.customer_key
                                   AND f2.product_key != f1.product_key
    WHERE
        dp.product_id = '&input_pid';

    dbms_output.put_line('Other products bought by same customers: ' || v_count);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Diagnostic error: ' || sqlerrm);
END;
/

-- ============================================================
-- Create PROCEDURE
-- ============================================================
CREATE OR REPLACE PROCEDURE get_product_recommendations (
    p_product_id IN VARCHAR2
) AS

    TYPE t_rec IS RECORD (
            v_pid   VARCHAR2(100),
            v_pname VARCHAR2(200),
            v_brand VARCHAR2(100),
            v_cat   VARCHAR2(100),
            v_inv   NUMBER,
            v_score NUMBER,
            v_freq  NUMBER,
            v_rec   NUMBER,
            v_cats  NUMBER,
            v_assoc NUMBER,
            v_prof  NUMBER,
            v_stk   NUMBER
    );
    TYPE t_tab IS
        TABLE OF t_rec;
    v_results t_tab;
    v_rank    NUMBER := 0;
BEGIN
    SELECT
        dp.product_id,
        dp.product_name,
        dp.brand,
        dc.category_name,
        dp.current_inventory_amount,
        round((coalesce(sf.freq_score, 0) * 0.25) +(coalesce(sr.rec_score, 0) * 0.20) +(coalesce(sc.cat_score, 0) * 0.15) +(coalesce(
        sa.assoc_score, 0) * 0.15) +(coalesce(sp.prof_score, 0) * 0.15) +(coalesce(ss.stk_score, 0) * 0.10),
              4),
        coalesce(sf.freq_score, 0),
        coalesce(sr.rec_score, 0),
        coalesce(sc.cat_score, 0),
        coalesce(sa.assoc_score, 0),
        coalesce(sp.prof_score, 0),
        coalesce(ss.stk_score, 0)
    BULK COLLECT
    INTO v_results
    FROM
             (
            SELECT
                f2.product_key,
                COUNT(DISTINCT
                    CASE
                        WHEN f1.order_id = f2.order_id THEN
                            f2.order_id
                    END
                )                               AS basket_count,
                COUNT(DISTINCT f1.customer_key) AS customer_count,
                MAX(d.full_date)                AS last_date
            FROM
                     fact_order_line f1
                JOIN fact_order_line f2 ON f1.customer_key = f2.customer_key
                                           AND f2.product_key != f1.product_key
                JOIN dim_date        d ON f2.date_key = d.date_key
                JOIN dim_product     dpin ON f1.product_key = dpin.product_key
            WHERE
                dpin.product_id = p_product_id
            GROUP BY
                f2.product_key
        ) cp
        JOIN dim_product     dp ON cp.product_key = dp.product_key
        JOIN fact_order_line fi ON dp.product_key = fi.product_key
        JOIN dim_category    dc ON fi.category_key = dc.category_key
        LEFT JOIN (
            SELECT
                product_key,
                round((basket_count + customer_count) / nullif(MAX(basket_count + customer_count)
                                                               OVER(),
                                                               0),
                      4) AS freq_score
            FROM
                (
                    SELECT
                        f2.product_key,
                        COUNT(DISTINCT
                            CASE
                                WHEN f1.order_id = f2.order_id THEN
                                    f2.order_id
                            END
                        )                               AS basket_count,
                        COUNT(DISTINCT f1.customer_key) AS customer_count
                    FROM
                             fact_order_line f1
                        JOIN fact_order_line f2 ON f1.customer_key = f2.customer_key
                                                   AND f2.product_key != f1.product_key
                        JOIN dim_product     dpin ON f1.product_key = dpin.product_key
                    WHERE
                        dpin.product_id = p_product_id
                    GROUP BY
                        f2.product_key
                )
        )               sf ON cp.product_key = sf.product_key
        LEFT JOIN (
            SELECT
                product_key,
                round(
                    CASE
                        WHEN sysdate - last_date <= 30 THEN
                            1.0
                        WHEN sysdate - last_date <= 60 THEN
                            0.7
                        WHEN sysdate - last_date <= 90 THEN
                            0.4
                        ELSE 0.1
                    END, 4) AS rec_score
            FROM
                (
                    SELECT
                        f2.product_key,
                        MAX(d.full_date) AS last_date
                    FROM
                             fact_order_line f1
                        JOIN fact_order_line f2 ON f1.customer_key = f2.customer_key
                                                   AND f2.product_key != f1.product_key
                        JOIN dim_date        d ON f2.date_key = d.date_key
                        JOIN dim_product     dpin ON f1.product_key = dpin.product_key
                    WHERE
                        dpin.product_id = p_product_id
                    GROUP BY
                        f2.product_key
                )
        )               sr ON cp.product_key = sr.product_key
        LEFT JOIN (
            SELECT
                f2.product_key,
                round(
                    max(
                        CASE
                            WHEN f2.category_key = f1.category_key THEN
                                1.0
                            WHEN dc2.parent_category = dc1.parent_category THEN
                                0.5
                            ELSE 0.1
                        END
                    ),
                    4
                ) AS cat_score
            FROM
                     fact_order_line f1
                JOIN fact_order_line f2 ON f1.customer_key = f2.customer_key
                                           AND f2.product_key != f1.product_key
                JOIN dim_category    dc1 ON f1.category_key = dc1.category_key
                JOIN dim_category    dc2 ON f2.category_key = dc2.category_key
                JOIN dim_product     dpin ON f1.product_key = dpin.product_key
            WHERE
                dpin.product_id = p_product_id
            GROUP BY
                f2.product_key
        )               sc ON cp.product_key = sc.product_key
        LEFT JOIN (
            SELECT
                product_key,
                round(
                    least((cust_overlap / nullif(total_cust, 0)) / nullif(prod_cust / nullif(total_cust, 0),
                                                                          0) / 10,
                          1.0),
                    4
                ) AS assoc_score
            FROM
                (
                    SELECT
                        f2.product_key,
                        COUNT(DISTINCT f1.customer_key) AS cust_overlap,
                        (
                            SELECT
                                COUNT(DISTINCT customer_key)
                            FROM
                                fact_order_line
                            WHERE
                                product_key = f2.product_key
                        )                               AS prod_cust,
                        (
                            SELECT
                                COUNT(DISTINCT f1b.customer_key)
                            FROM
                                     fact_order_line f1b
                                JOIN dim_product dpin2 ON f1b.product_key = dpin2.product_key
                            WHERE
                                dpin2.product_id = p_product_id
                        )                               AS total_cust
                    FROM
                             fact_order_line f1
                        JOIN fact_order_line f2 ON f1.customer_key = f2.customer_key
                                                   AND f2.product_key != f1.product_key
                        JOIN dim_product     dpin ON f1.product_key = dpin.product_key
                    WHERE
                        dpin.product_id = p_product_id
                    GROUP BY
                        f2.product_key
                )
        )               sa ON cp.product_key = sa.product_key
        LEFT JOIN (
            SELECT
                product_key,
                round((avg_pm / nullif(MAX(avg_pm)
                                       OVER(),
                                       0) * 0.6) +(ord_cnt / nullif(MAX(ord_cnt)
                                                                    OVER(),
                                                                    0) * 0.4),
                      4) AS prof_score
            FROM
                (
                    SELECT
                        product_key,
                        AVG(profit_margin) AS avg_pm,
                        COUNT(order_id)    AS ord_cnt
                    FROM
                        fact_order_line
                    GROUP BY
                        product_key
                )
        )               sp ON cp.product_key = sp.product_key
        LEFT JOIN (
            SELECT
                product_key,
                round(current_inventory_amount / nullif(MAX(current_inventory_amount)
                                                        OVER(),
                                                        0),
                      4) AS stk_score
            FROM
                dim_product
        )               ss ON cp.product_key = ss.product_key
    GROUP BY
        dp.product_id,
        dp.product_name,
        dp.brand,
        dc.category_name,
        dp.current_inventory_amount,
        sf.freq_score,
        sr.rec_score,
        sc.cat_score,
        sa.assoc_score,
        sp.prof_score,
        ss.stk_score
    ORDER BY
        6 DESC
    FETCH FIRST 4 ROWS ONLY;

    dbms_output.put_line('=== TOP 4 RECOMMENDATIONS FOR: '
                         || p_product_id
                         || ' ===');
    dbms_output.put_line(rpad('Rank', 5)
                         || rpad('Product ID', 14)
                         || rpad('Name', 25)
                         || rpad('Brand', 14)
                         || rpad('Category', 18)
                         || rpad('Stock', 8)
                         || 'Score');

    dbms_output.put_line(rpad('-', 92, '-'));
    FOR i IN 1..v_results.count LOOP
        v_rank := v_rank + 1;
        dbms_output.put_line(rpad(v_rank, 5)
                             || rpad(v_results(i).v_pid,
                                     14)
                             || rpad(v_results(i).v_pname,
                                     25)
                             || rpad(v_results(i).v_brand,
                                     14)
                             || rpad(v_results(i).v_cat,
                                     18)
                             || rpad(v_results(i).v_inv,
                                     8)
                             || v_results(i).v_score);

    END LOOP;

    IF v_rank = 0 THEN
        dbms_output.put_line('No recommendations found for: ' || p_product_id);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error: ' || sqlerrm);
END get_product_recommendations;
/

-- ============================================================
--  CALL THE PROCEDURE
-- ============================================================
EXEC get_product_recommendations('&input_pid');