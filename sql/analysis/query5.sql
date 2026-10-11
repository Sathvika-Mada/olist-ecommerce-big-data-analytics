
-- Query 5: Delivery performance by customer state

WITH state_delivery AS (
    SELECT
        customer_state,
        COUNT(*) AS delivered_orders,
        ROUND(
            AVG(delivery_delay_days)::numeric,
            2
        ) AS avg_delivery_delay_days,
        COUNT(*) FILTER (
            WHERE delivery_delay_days > 0
        ) AS late_orders
    FROM mart.order_summary
    WHERE order_status = 'delivered'
      AND delivered_date IS NOT NULL
      AND estimated_delivery_date IS NOT NULL
      AND customer_state IS NOT NULL
    GROUP BY customer_state
),
ranked_states AS (
    SELECT
        customer_state,
        delivered_orders,
        avg_delivery_delay_days,
        late_orders,
        ROUND(
            100.0 * late_orders / NULLIF(delivered_orders, 0),
            2
        ) AS late_delivery_percentage,
        DENSE_RANK() OVER (
            ORDER BY
                100.0 * late_orders / NULLIF(delivered_orders, 0) DESC
        ) AS delay_rank
    FROM state_delivery
)
SELECT *
FROM ranked_states
ORDER BY delay_rank, customer_state;
