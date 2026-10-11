
-- Check 3: Payment mismatch

WITH item_totals AS (
    SELECT
        order_id,
        SUM(price + freight_value) AS expected_total
    FROM staging.order_items
    GROUP BY order_id
),
payment_totals AS (
    SELECT
        order_id,
        SUM(payment_value) AS actual_total
    FROM staging.payments
    GROUP BY order_id
)
SELECT
    COUNT(*) AS payment_mismatches
FROM item_totals i
JOIN payment_totals p
    ON i.order_id = p.order_id
WHERE ABS(i.expected_total - p.actual_total) > 0.01;
