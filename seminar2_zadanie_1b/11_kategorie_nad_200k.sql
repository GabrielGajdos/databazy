SELECT *
FROM flourmills_sales AS s
WHERE EXISTS (
    SELECT 1
    FROM flourmills_sales AS s2
    WHERE s2.product_category = s.product_category
      AND s2.total_amount > 200000
);