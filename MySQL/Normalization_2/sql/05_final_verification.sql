-- Итоговый компактный контроль для повторного запуска и третьего скриншота.
USE sales_norm_2;

SELECT
    (SELECT COUNT(*) FROM sales_unnormalized) AS source_rows,
    (SELECT COUNT(*) FROM clients) AS clients,
    (SELECT COUNT(*) FROM products) AS products,
    (SELECT COUNT(*) FROM sales) AS sales,
    (SELECT COUNT(*) FROM sale_items) AS sale_items;

SELECT
    (SELECT SUM(unit_price * quantity) FROM sales_unnormalized) AS source_total,
    (SELECT SUM(p.unit_price * si.quantity)
       FROM sale_items AS si
       JOIN products AS p ON p.product_id = si.product_id) AS normalized_total;

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

SELECT
    (SELECT COUNT(*)
       FROM sales AS s LEFT JOIN clients AS c ON c.client_id = s.client_id
      WHERE c.client_id IS NULL) AS sales_without_client,
    (SELECT COUNT(*)
       FROM sale_items AS si LEFT JOIN sales AS s ON s.sale_id = si.sale_id
      WHERE s.sale_id IS NULL) AS items_without_sale,
    (SELECT COUNT(*)
       FROM sale_items AS si LEFT JOIN products AS p ON p.product_id = si.product_id
      WHERE p.product_id IS NULL) AS items_without_product;
