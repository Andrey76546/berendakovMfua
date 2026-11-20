-- Этап 2. Все опасные действия выполняются на тестовой копии и откатываются.
USE sales_norm_2;

CREATE TABLE sales_unnormalized_anomaly_demo LIKE sales_unnormalized;
INSERT INTO sales_unnormalized_anomaly_demo
SELECT * FROM sales_unnormalized;

SELECT 'UPDATE ANOMALY' AS demonstration;
START TRANSACTION;
UPDATE sales_unnormalized_anomaly_demo
SET client_city = 'Тверь'
WHERE client_id = 101
  AND sale_id = 5001
  AND product_id = 201;
SELECT sale_id, product_id, client_id, client_name, client_city
FROM sales_unnormalized_anomaly_demo
WHERE client_id = 101
ORDER BY sale_id, product_id;
SELECT COUNT(DISTINCT client_city) AS conflicting_cities_for_one_client
FROM sales_unnormalized_anomaly_demo
WHERE client_id = 101;
ROLLBACK;

SELECT 'INSERT ANOMALY' AS demonstration;
START TRANSACTION;
INSERT INTO sales_unnormalized_anomaly_demo
    (client_id, client_name, client_city)
VALUES
    (104, 'Орлов Олег', 'Тула');
SELECT sale_id, sale_date, client_id, client_name, client_city,
       product_id, product_name, unit_price, quantity
FROM sales_unnormalized_anomaly_demo
WHERE client_id = 104;
SELECT COUNT(*) AS malformed_rows_required_for_client_without_sale
FROM sales_unnormalized_anomaly_demo
WHERE client_id = 104
  AND sale_id IS NULL
  AND product_id IS NULL;
ROLLBACK;

SELECT 'DELETE ANOMALY' AS demonstration;
START TRANSACTION;
SELECT COUNT(*) AS client_102_rows_before_delete
FROM sales_unnormalized_anomaly_demo
WHERE client_id = 102;
DELETE FROM sales_unnormalized_anomaly_demo
WHERE client_id = 102;
SELECT COUNT(*) AS client_102_rows_after_delete
FROM sales_unnormalized_anomaly_demo
WHERE client_id = 102;
ROLLBACK;

SELECT COUNT(*) AS source_rows_after_demonstrations,
       SUM(unit_price * quantity) AS source_total_after_demonstrations
FROM sales_unnormalized;

DROP TABLE sales_unnormalized_anomaly_demo;
