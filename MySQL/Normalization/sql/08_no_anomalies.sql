USE shop_norm;

SELECT * FROM orders_bad WHERE customer_name = 'Иван';

UPDATE customers_3nf SET customer_city = 'Сочи' WHERE customer_name = 'Иван';
SELECT ROW_COUNT() AS ivan_rows_updated;
SELECT * FROM customers_3nf WHERE customer_name = 'Иван';

DELETE FROM order_items_3nf
WHERE order_id IN (
    SELECT o.order_id
    FROM orders_3nf o
    JOIN customers_3nf c ON o.customer_id = c.customer_id
    WHERE c.customer_name = 'Мария'
);

DELETE FROM orders_3nf
WHERE customer_id IN (
    SELECT customer_id FROM customers_3nf WHERE customer_name = 'Мария'
);

SELECT * FROM customers_3nf WHERE customer_name = 'Мария';

INSERT INTO customers_3nf (customer_name, customer_city)
VALUES ('Новый клиент', 'Тверь');

SELECT * FROM customers_3nf WHERE customer_name = 'Новый клиент';
