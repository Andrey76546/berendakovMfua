USE shop_norm;

DELETE FROM orders_bad WHERE customer_name = 'Новый клиент';

SELECT COUNT(*) AS test_rows_after_cleanup
FROM orders_bad
WHERE customer_name = 'Новый клиент';
