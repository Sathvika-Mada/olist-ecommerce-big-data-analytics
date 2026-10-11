
-- North Star Metric: Monthly Delivered GMV

SELECT
    DATE_TRUNC('month', o.purchase_date)::date AS month,
    ROUND(SUM(oi.price), 2) AS monthly_gmv
FROM staging.orders o
JOIN staging.order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND o.purchase_date IS NOT NULL
GROUP BY 1
ORDER BY 1;
