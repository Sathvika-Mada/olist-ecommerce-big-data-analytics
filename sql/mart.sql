
DROP TABLE IF EXISTS mart.order_summary;

CREATE TABLE mart.order_summary AS

WITH item_totals AS (
    SELECT
        order_id,
        COUNT(*) AS item_count,
        SUM(price) AS item_price,
        SUM(freight_value) AS freight_total
    FROM staging.order_items
    GROUP BY order_id
),

payment_totals AS (
    SELECT
        order_id,
        SUM(payment_value) AS payment_total
    FROM staging.payments
    GROUP BY order_id
),

review_summary AS (
    SELECT
        order_id,
        AVG(review_score) AS review_score
    FROM staging.reviews
    GROUP BY order_id
)

SELECT
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    c.customer_state,
    o.order_status,
    o.purchase_date,
    o.delivered_date,
    o.estimated_delivery_date,

    COALESCE(i.item_count, 0) AS item_count,
    COALESCE(i.item_price, 0) AS item_price,
    COALESCE(i.freight_total, 0) AS freight_total,

    COALESCE(i.item_price, 0)
      + COALESCE(i.freight_total, 0) AS order_total,

    p.payment_total,
    r.review_score,

    CASE
        WHEN o.delivered_date IS NOT NULL
         AND o.estimated_delivery_date IS NOT NULL
        THEN EXTRACT(
            EPOCH FROM (
                o.delivered_date - o.estimated_delivery_date
            )
        ) / 86400.0
        ELSE NULL
    END AS delivery_delay_days

FROM staging.orders o

LEFT JOIN staging.customers c
    ON o.customer_id = c.customer_id

LEFT JOIN item_totals i
    ON o.order_id = i.order_id

LEFT JOIN payment_totals p
    ON o.order_id = p.order_id

LEFT JOIN review_summary r
    ON o.order_id = r.order_id;