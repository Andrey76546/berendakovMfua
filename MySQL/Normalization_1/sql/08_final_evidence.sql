USE normalization_1;

SELECT r.report_id, DATE_FORMAT(r.report_date, '%Y-%m-%d') AS report_date,
       c.customer_name, p.product_name, p.price, ri.quantity,
       p.price * ri.quantity AS line_total
FROM reports AS r
JOIN customers AS c ON c.customer_id = r.customer_id
JOIN report_items AS ri ON ri.report_id = r.report_id
JOIN products AS p ON p.product_id = ri.product_id
ORDER BY r.report_id, p.product_id;

SELECT 'archived rows = report items' AS check_name,
       (SELECT COUNT(*) FROM sales_unnormalized_2_archived) AS expected,
       (SELECT COUNT(*) FROM report_items) AS actual,
       IF((SELECT COUNT(*) FROM sales_unnormalized_2_archived) =
          (SELECT COUNT(*) FROM report_items), 'PASS', 'FAIL') AS result
UNION ALL
SELECT 'reports', 5, (SELECT COUNT(*) FROM reports),
       IF((SELECT COUNT(*) FROM reports) = 5, 'PASS', 'FAIL')
UNION ALL
SELECT 'customers', 3, (SELECT COUNT(*) FROM customers),
       IF((SELECT COUNT(*) FROM customers) = 3, 'PASS', 'FAIL')
UNION ALL
SELECT 'products', 4, (SELECT COUNT(*) FROM products),
       IF((SELECT COUNT(*) FROM products) = 4, 'PASS', 'FAIL')
UNION ALL
SELECT 'total amount', 3609000.00,
       (SELECT SUM(p.price * ri.quantity)
        FROM report_items AS ri
        JOIN products AS p ON p.product_id = ri.product_id),
       IF((SELECT SUM(p.price * ri.quantity)
           FROM report_items AS ri
           JOIN products AS p ON p.product_id = ri.product_id) = 3609000.00,
          'PASS', 'FAIL')
UNION ALL
SELECT 'customer 12 amount', 2925000.00,
       (SELECT SUM(p.price * ri.quantity)
        FROM reports AS r
        JOIN report_items AS ri ON ri.report_id = r.report_id
        JOIN products AS p ON p.product_id = ri.product_id
        WHERE r.customer_id = 12),
       IF((SELECT SUM(p.price * ri.quantity)
           FROM reports AS r
           JOIN report_items AS ri ON ri.report_id = r.report_id
           JOIN products AS p ON p.product_id = ri.product_id
           WHERE r.customer_id = 12) = 2925000.00,
          'PASS', 'FAIL')
UNION ALL
SELECT 'orphan foreign keys', 0,
       ((SELECT COUNT(*) FROM reports AS r LEFT JOIN customers AS c
         ON c.customer_id = r.customer_id WHERE c.customer_id IS NULL) +
        (SELECT COUNT(*) FROM report_items AS ri LEFT JOIN reports AS r
         ON r.report_id = ri.report_id WHERE r.report_id IS NULL) +
        (SELECT COUNT(*) FROM report_items AS ri LEFT JOIN products AS p
         ON p.product_id = ri.product_id WHERE p.product_id IS NULL)),
       IF(((SELECT COUNT(*) FROM reports AS r LEFT JOIN customers AS c
            ON c.customer_id = r.customer_id WHERE c.customer_id IS NULL) +
           (SELECT COUNT(*) FROM report_items AS ri LEFT JOIN reports AS r
            ON r.report_id = ri.report_id WHERE r.report_id IS NULL) +
           (SELECT COUNT(*) FROM report_items AS ri LEFT JOIN products AS p
            ON p.product_id = ri.product_id WHERE p.product_id IS NULL)) = 0,
          'PASS', 'FAIL');
