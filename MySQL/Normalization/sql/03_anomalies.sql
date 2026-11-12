USE shop_norm;

UPDATE orders_bad
SET customer_city = 'Сочи'
WHERE order_id = 1;

SELECT * FROM orders_bad WHERE customer_name = 'Иван';

DELETE FROM orders_bad WHERE order_id = 4;

SELECT * FROM orders_bad WHERE customer_name = 'Мария';

INSERT INTO orders_bad (customer_name, customer_city)
VALUES ('Новый клиент', 'Тверь');

SELECT * FROM orders_bad WHERE customer_name = 'Новый клиент';
