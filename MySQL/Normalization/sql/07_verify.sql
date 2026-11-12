USE shop_norm;

SELECT SUM(product_price * quantity) AS total_old
FROM orders_bad;

SELECT SUM(p.product_price * oi.quantity) AS total_new
FROM order_items_3nf oi
JOIN products_3nf p ON oi.product_id = p.product_id;

SELECT COUNT(DISTINCT order_id) AS old_count FROM orders_bad;
SELECT COUNT(*) AS new_count FROM orders_3nf;

SELECT COUNT(*) AS old_count FROM
  (SELECT DISTINCT customer_name, customer_city FROM orders_bad) AS t;
SELECT COUNT(*) AS new_count FROM customers_3nf;

SELECT COUNT(*) AS old_count FROM
  (SELECT DISTINCT product_name, product_price FROM orders_bad) AS t;
SELECT COUNT(*) AS new_count FROM products_3nf;

SELECT SUM(p.product_price * oi.quantity) AS total
FROM customers_3nf c
JOIN orders_3nf o       ON c.customer_id = o.customer_id
JOIN order_items_3nf oi ON o.order_id = oi.order_id
JOIN products_3nf p     ON oi.product_id = p.product_id
WHERE c.customer_name = 'Иван';
