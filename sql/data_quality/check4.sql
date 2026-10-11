-- Check 4: Orders without matching customers

SELECT
    COUNT(*) AS missing_customers
FROM staging.orders o
LEFT JOIN staging.customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;