
-- Query 1: Monthly revenue and month-over-month growth

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', purchase_date)::date AS month,
        SUM(order_total) AS revenue
    FROM mart.order_summary
    WHERE order_status = 'delivered'
      AND purchase_date IS NOT NULL
    GROUP BY 1
),
revenue_comparison AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(
        100.0 * (revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS growth_percentage
FROM revenue_comparison
ORDER BY month;
