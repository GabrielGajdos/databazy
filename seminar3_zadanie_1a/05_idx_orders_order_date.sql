CREATE INDEX idx_orders_order_date
ON orders(order_date);

SELECT
    DATE_TRUNC('month', order_date) AS mesiac,
    SUM(sales) AS celkovy_predaj
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY mesiac ASC;