-- Этап 5. Полная проверка данных, ограничений и устранения аномалий.
USE sales_norm_2;

SELECT 'COUNTS' AS verification;
SELECT
    (SELECT COUNT(*) FROM sales_unnormalized) AS source_rows,
    (SELECT COUNT(*) FROM clients) AS clients,
    (SELECT COUNT(*) FROM products) AS products,
    (SELECT COUNT(*) FROM sales) AS sales,
    (SELECT COUNT(*) FROM sale_items) AS sale_items;

SELECT 'ALL CLIENTS' AS verification;
SELECT * FROM clients ORDER BY client_id;

SELECT 'ALL PRODUCTS' AS verification;
SELECT * FROM products ORDER BY product_id;

SELECT 'ALL SALES' AS verification;
SELECT * FROM sales ORDER BY sale_id;

SELECT 'ALL SALE ITEMS' AS verification;
SELECT * FROM sale_items ORDER BY sale_id, product_id;

SELECT 'PRIMARY, FOREIGN AND CHECK CONSTRAINTS' AS verification;
SELECT table_name, constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE constraint_schema = 'sales_norm_2'
  AND table_name IN ('clients', 'products', 'sales', 'sale_items')
ORDER BY table_name, constraint_type, constraint_name;

SELECT 'FOREIGN KEY LINKS' AS verification;
SELECT table_name, column_name, constraint_name,
       referenced_table_name, referenced_column_name
FROM information_schema.key_column_usage
WHERE constraint_schema = 'sales_norm_2'
  AND referenced_table_name IS NOT NULL
ORDER BY table_name, constraint_name, ordinal_position;

SELECT 'TOTALS' AS verification;
SELECT
    (SELECT SUM(unit_price * quantity)
       FROM sales_unnormalized) AS source_total,
    (SELECT SUM(p.unit_price * si.quantity)
       FROM sale_items AS si
       JOIN products AS p ON p.product_id = si.product_id) AS normalized_total;

SELECT 'RECONSTRUCTED SOURCE ROWS' AS verification;
SELECT s.sale_id, s.sale_date,
       c.client_id, c.client_name, c.client_city,
       p.product_id, p.product_name, p.unit_price,
       si.quantity
FROM sales AS s
JOIN clients AS c ON c.client_id = s.client_id
JOIN sale_items AS si ON si.sale_id = s.sale_id
JOIN products AS p ON p.product_id = si.product_id
ORDER BY s.sale_id, p.product_id;

SELECT 'ROW-BY-ROW EQUALITY' AS verification;
SELECT COUNT(*) AS reconstructed_rows,
       SUM(CASE
             WHEN s.sale_date = u.sale_date
              AND c.client_id = u.client_id
              AND c.client_name = u.client_name
              AND c.client_city = u.client_city
              AND p.product_name = u.product_name
              AND p.unit_price = u.unit_price
              AND si.quantity = u.quantity
             THEN 0 ELSE 1
           END) AS mismatched_rows
FROM sales_unnormalized AS u
JOIN sales AS s ON s.sale_id = u.sale_id
JOIN clients AS c ON c.client_id = s.client_id
JOIN sale_items AS si
  ON si.sale_id = u.sale_id AND si.product_id = u.product_id
JOIN products AS p ON p.product_id = si.product_id;

SELECT 'ORPHAN CHECKS' AS verification;
SELECT
    (SELECT COUNT(*)
       FROM sales AS s
       LEFT JOIN clients AS c ON c.client_id = s.client_id
      WHERE c.client_id IS NULL) AS sales_without_client,
    (SELECT COUNT(*)
       FROM sale_items AS si
       LEFT JOIN sales AS s ON s.sale_id = si.sale_id
      WHERE s.sale_id IS NULL) AS items_without_sale,
    (SELECT COUNT(*)
       FROM sale_items AS si
       LEFT JOIN products AS p ON p.product_id = si.product_id
      WHERE p.product_id IS NULL) AS items_without_product;

SELECT 'UPDATE WITHOUT ANOMALY' AS verification;
START TRANSACTION;
UPDATE clients SET client_city = 'Тверь' WHERE client_id = 101;
SELECT ROW_COUNT() AS rows_changed_in_one_place;
SELECT client_id, client_name, client_city
FROM clients WHERE client_id = 101;
SELECT s.sale_id, p.product_id, c.client_city
FROM sales AS s
JOIN clients AS c ON c.client_id = s.client_id
JOIN sale_items AS si ON si.sale_id = s.sale_id
JOIN products AS p ON p.product_id = si.product_id
WHERE c.client_id = 101
ORDER BY s.sale_id, p.product_id;
ROLLBACK;

SELECT 'INSERT WITHOUT ANOMALY' AS verification;
START TRANSACTION;
INSERT INTO clients (client_id, client_name, client_city)
VALUES (104, 'Орлов Олег', 'Тула');
SELECT c.client_id, c.client_name, c.client_city,
       COUNT(s.sale_id) AS sale_count
FROM clients AS c
LEFT JOIN sales AS s ON s.client_id = c.client_id
WHERE c.client_id = 104
GROUP BY c.client_id, c.client_name, c.client_city;
ROLLBACK;

SELECT 'DELETE WITHOUT ANOMALY' AS verification;
START TRANSACTION;
DELETE FROM sale_items WHERE sale_id = 5005;
DELETE FROM sales WHERE sale_id = 5005;
SELECT c.client_id, c.client_name, c.client_city,
       COUNT(s.sale_id) AS remaining_sales
FROM clients AS c
LEFT JOIN sales AS s ON s.client_id = c.client_id
WHERE c.client_id = 102
GROUP BY c.client_id, c.client_name, c.client_city;
ROLLBACK;

SELECT 'FINAL STATE AFTER ROLLBACKS' AS verification;
SELECT
    (SELECT COUNT(*) FROM clients) AS clients,
    (SELECT COUNT(*) FROM products) AS products,
    (SELECT COUNT(*) FROM sales) AS sales,
    (SELECT COUNT(*) FROM sale_items) AS sale_items,
    (SELECT SUM(p.unit_price * si.quantity)
       FROM sale_items AS si
       JOIN products AS p ON p.product_id = si.product_id) AS normalized_total;
