
-- Query 4: Repeat customer purchase analysis

WITH customer_orders AS (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM mart.order_summary
    WHERE customer_unique_id IS NOT NULL
      AND order_status = 'delivered'
    GROUP BY customer_unique_id
),
customer_segments AS (
    SELECT
        customer_unique_id,
        total_orders,
        CASE
            WHEN total_orders = 1 THEN 'One-time'
            ELSE 'Repeat'
        END AS customer_type
    FROM customer_orders
)
SELECT
    customer_type,
    COUNT(*) AS customer_count,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_customers
FROM customer_segments
GROUP BY customer_type
ORDER BY customer_type;
