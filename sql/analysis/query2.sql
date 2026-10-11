
-- Query 2: Top 10 product categories by revenue

WITH category_revenue AS (
    SELECT
        COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'Unknown'
        ) AS category,
        SUM(oi.price) AS revenue
    FROM staging.order_items oi

    JOIN staging.orders o
        ON oi.order_id = o.order_id

    LEFT JOIN staging.products p
        ON oi.product_id = p.product_id

    LEFT JOIN staging.category_translation t
        ON p.product_category_name =
           t.product_category_name

    WHERE o.order_status = 'delivered'

    GROUP BY 1
),
ranked_categories AS (
    SELECT
        category,
        ROUND(revenue, 2) AS revenue,
        DENSE_RANK() OVER (
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM category_revenue
)
SELECT
    revenue_rank,
    category,
    revenue
FROM ranked_categories
WHERE revenue_rank <= 10
ORDER BY revenue_rank, category;
