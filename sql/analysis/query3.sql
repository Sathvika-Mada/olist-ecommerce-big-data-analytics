
-- Query 3: Daily revenue and 7-day rolling average

WITH daily_revenue AS (
    SELECT
        purchase_date::date AS order_date,
        SUM(order_total) AS revenue
    FROM mart.order_summary
    WHERE order_status = 'delivered'
      AND purchase_date IS NOT NULL
    GROUP BY purchase_date::date
)
SELECT
    order_date,
    ROUND(revenue, 2) AS daily_revenue,
    ROUND(
        AVG(revenue) OVER (
            ORDER BY order_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS rolling_7_day_avg
FROM daily_revenue
ORDER BY order_date;
