USE normalization_1;

SELECT 'source rows = report items' AS check_name,
       (SELECT COUNT(*) FROM sales_unnormalized_2) AS source_value,
       (SELECT COUNT(*) FROM report_items) AS normalized_value,
       IF((SELECT COUNT(*) FROM sales_unnormalized_2) =
          (SELECT COUNT(*) FROM report_items), 'PASS', 'FAIL') AS result
UNION ALL
SELECT 'distinct reports = reports',
       (SELECT COUNT(DISTINCT report_id) FROM sales_unnormalized_2),
       (SELECT COUNT(*) FROM reports),
       IF((SELECT COUNT(DISTINCT report_id) FROM sales_unnormalized_2) =
          (SELECT COUNT(*) FROM reports), 'PASS', 'FAIL')
UNION ALL
SELECT 'distinct customers = customers',
       (SELECT COUNT(DISTINCT customer_id) FROM sales_unnormalized_2),
       (SELECT COUNT(*) FROM customers),
       IF((SELECT COUNT(DISTINCT customer_id) FROM sales_unnormalized_2) =
          (SELECT COUNT(*) FROM customers), 'PASS', 'FAIL')
UNION ALL
SELECT 'distinct products = products',
       (SELECT COUNT(DISTINCT product_id) FROM sales_unnormalized_2),
       (SELECT COUNT(*) FROM products),
       IF((SELECT COUNT(DISTINCT product_id) FROM sales_unnormalized_2) =
          (SELECT COUNT(*) FROM products), 'PASS', 'FAIL');

SELECT SUM(price * quantity) AS source_total
FROM sales_unnormalized_2;

SELECT SUM(p.price * ri.quantity) AS normalized_total
FROM report_items AS ri
JOIN products AS p ON p.product_id = ri.product_id;

SELECT source_total, normalized_total,
       normalized_total - source_total AS difference,
       IF(source_total = normalized_total, 'PASS', 'FAIL') AS result
FROM
    (SELECT SUM(price * quantity) AS source_total
     FROM sales_unnormalized_2) AS source_sum
CROSS JOIN
    (SELECT SUM(p.price * ri.quantity) AS normalized_total
     FROM report_items AS ri
     JOIN products AS p ON p.product_id = ri.product_id) AS normalized_sum;

SELECT
    (SELECT COUNT(*)
     FROM reports AS r
     LEFT JOIN customers AS c ON c.customer_id = r.customer_id
     WHERE c.customer_id IS NULL) AS orphan_reports,
    (SELECT COUNT(*)
     FROM report_items AS ri
     LEFT JOIN reports AS r ON r.report_id = ri.report_id
     WHERE r.report_id IS NULL) AS orphan_report_items,
    (SELECT COUNT(*)
     FROM report_items AS ri
     LEFT JOIN products AS p ON p.product_id = ri.product_id
     WHERE p.product_id IS NULL) AS orphan_products,
    @@foreign_key_checks AS foreign_key_checks;

SELECT COUNT(*) AS source_rows_not_reconstructed
FROM sales_unnormalized_2 AS s
LEFT JOIN (
    SELECT r.report_id, r.report_date, c.customer_id, c.customer_name,
           p.product_id, p.product_name, p.price, ri.quantity
    FROM reports AS r
    JOIN customers AS c ON c.customer_id = r.customer_id
    JOIN report_items AS ri ON ri.report_id = r.report_id
    JOIN products AS p ON p.product_id = ri.product_id
) AS n
  ON n.report_id = s.report_id
 AND n.report_date = s.report_date
 AND n.customer_id = s.customer_id
 AND n.customer_name = s.customer_name
 AND n.product_id = s.product_id
 AND n.product_name = s.product_name
 AND n.price = s.price
 AND n.quantity = s.quantity
WHERE n.report_id IS NULL;

SELECT c.customer_id, c.customer_name,
       SUM(p.price * ri.quantity) AS amount_spent
FROM customers AS c
JOIN reports AS r ON r.customer_id = c.customer_id
JOIN report_items AS ri ON ri.report_id = r.report_id
JOIN products AS p ON p.product_id = ri.product_id
WHERE c.customer_id = 12
GROUP BY c.customer_id, c.customer_name;

SELECT c.customer_id, c.customer_name,
       SUM(p.price * ri.quantity) AS amount_spent
FROM customers AS c
JOIN reports AS r ON r.customer_id = c.customer_id
JOIN report_items AS ri ON ri.report_id = r.report_id
JOIN products AS p ON p.product_id = ri.product_id
GROUP BY c.customer_id, c.customer_name
ORDER BY c.customer_id;
