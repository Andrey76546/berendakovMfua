USE normalization_1;

SELECT 'UPDATE anomaly: one copy changes, the other copies become inconsistent' AS demonstration;
START TRANSACTION;
UPDATE sales_unnormalized_2
SET customer_name = 'Дания (изменена одна строка)'
WHERE report_id = 1101 AND product_id = 101;
SELECT report_id, product_id, customer_id, customer_name
FROM sales_unnormalized_2
WHERE customer_id = 12
ORDER BY report_id, product_id;
ROLLBACK;
SELECT IF(COUNT(DISTINCT customer_name) = 1, 'PASS: rollback restored the source', 'FAIL') AS rollback_check
FROM sales_unnormalized_2
WHERE customer_id = 12;

SELECT 'INSERT anomaly: a customer without a report requires a fake incomplete sales row' AS demonstration;
START TRANSACTION;
INSERT INTO sales_unnormalized_2
    (report_id, report_date, customer_id, customer_name,
     product_id, product_name, price, quantity)
VALUES
    (NULL, NULL, 30, 'Франция', NULL, NULL, NULL, NULL);
SELECT *
FROM sales_unnormalized_2
WHERE customer_id = 30;
ROLLBACK;
SELECT IF(COUNT(*) = 0, 'PASS: fake row removed by rollback', 'FAIL') AS rollback_check
FROM sales_unnormalized_2
WHERE customer_id = 30;

SELECT 'DELETE anomaly: deleting the only sale also loses the customer data' AS demonstration;
START TRANSACTION;
DELETE FROM sales_unnormalized_2
WHERE customer_id = 23;
SELECT COUNT(*) AS spanish_customer_rows_after_delete
FROM sales_unnormalized_2
WHERE customer_id = 23;
ROLLBACK;
SELECT IF(COUNT(*) = 1, 'PASS: rollback restored the source', 'FAIL') AS rollback_check
FROM sales_unnormalized_2
WHERE customer_id = 23;
