WITH customer_orders AS (
    SELECT
        o.customer_id,
        c.customer_name,
        o.order_date,
        MAX(o.order_date) OVER (
            PARTITION BY o.customer_id
        ) AS last_order_date,
        MAX(o.order_date) OVER () AS latest_order_date
    FROM orders AS o
    JOIN customers AS c
        ON o.customer_id = c.customer_id
),
inactive_customers AS (
    SELECT DISTINCT
        customer_id,
        customer_name,
        last_order_date
    FROM customer_orders
    WHERE last_order_date < latest_order_date - INTERVAL '90 days'
)
SELECT
    customer_id,
    customer_name,
    last_order_date
FROM inactive_customers
ORDER BY last_order_date ASC;