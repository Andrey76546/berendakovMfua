-- Этап 4. Перенос только через INSERT ... SELECT из исходной таблицы.
USE sales_norm_2;

START TRANSACTION;

INSERT INTO clients (client_id, client_name, client_city)
SELECT DISTINCT client_id, client_name, client_city
FROM sales_unnormalized;

INSERT INTO products (product_id, product_name, unit_price)
SELECT DISTINCT product_id, product_name, unit_price
FROM sales_unnormalized;

INSERT INTO sales (sale_id, sale_date, client_id)
SELECT DISTINCT sale_id, sale_date, client_id
FROM sales_unnormalized;

INSERT INTO sale_items (sale_id, product_id, quantity)
SELECT sale_id, product_id, quantity
FROM sales_unnormalized;

COMMIT;

SELECT
    (SELECT COUNT(*) FROM clients) AS clients,
    (SELECT COUNT(*) FROM products) AS products,
    (SELECT COUNT(*) FROM sales) AS sales,
    (SELECT COUNT(*) FROM sale_items) AS sale_items;
