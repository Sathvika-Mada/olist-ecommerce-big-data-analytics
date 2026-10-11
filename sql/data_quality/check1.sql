
-- Check 1: Null or duplicate order IDs

SELECT
    COUNT(*) FILTER (
        WHERE order_id IS NULL OR TRIM(order_id) = ''
    ) AS null_order_ids,

    COUNT(*) - COUNT(DISTINCT order_id)
        AS duplicate_order_ids

FROM staging.orders;
