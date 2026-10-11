
-- Check 2: Delivered date earlier than purchase date

SELECT
    COUNT(*) AS invalid_delivery_dates
FROM staging.orders
WHERE delivered_date < purchase_date;
