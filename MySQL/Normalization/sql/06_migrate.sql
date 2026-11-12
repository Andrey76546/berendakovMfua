USE shop_norm;

INSERT INTO customers_3nf (customer_name, customer_city)
SELECT DISTINCT customer_name, customer_city
FROM orders_bad;

INSERT INTO products_3nf (product_name, product_price)
SELECT DISTINCT product_name, product_price
FROM orders_bad;

INSERT INTO orders_3nf (order_id, customer_id, order_date)
SELECT o.order_id, c.customer_id, o.order_date
FROM orders_bad o
JOIN customers_3nf c
  ON c.customer_name = o.customer_name
 AND c.customer_city = o.customer_city;

INSERT INTO order_items_3nf (order_id, product_id, quantity)
SELECT o.order_id, p.product_id, o.quantity
FROM orders_bad o
JOIN products_3nf p
  ON p.product_name = o.product_name
 AND p.product_price = o.product_price;

SELECT * FROM customers_3nf;
SELECT * FROM products_3nf;
SELECT * FROM orders_3nf;
SELECT * FROM order_items_3nf;
