USE normalization_1;

SELECT 'UPDATE: customer name is stored once and all joined rows see the same value' AS demonstration;
START TRANSACTION;
UPDATE customers
SET customer_name = 'Дания (единое обновление)'
WHERE customer_id = 12;
SELECT r.report_id, ri.product_id, c.customer_id, c.customer_name
FROM customers AS c
JOIN reports AS r ON r.customer_id = c.customer_id
JOIN report_items AS ri ON ri.report_id = r.report_id
WHERE c.customer_id = 12
ORDER BY r.report_id, ri.product_id;
ROLLBACK;

SELECT 'INSERT: a customer can exist without a fake report or sale row' AS demonstration;
START TRANSACTION;
INSERT INTO customers (customer_id, customer_name)
VALUES (30, 'Франция');
SELECT c.customer_id, c.customer_name, COUNT(r.report_id) AS reports_count
FROM customers AS c
LEFT JOIN reports AS r ON r.customer_id = c.customer_id
WHERE c.customer_id = 30
GROUP BY c.customer_id, c.customer_name;
ROLLBACK;

DROP PROCEDURE IF EXISTS demonstrate_delete_protection;
DELIMITER //
CREATE PROCEDURE demonstrate_delete_protection()
BEGIN
    DECLARE fk_blocked BOOLEAN DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR 1451 SET fk_blocked = TRUE;

    START TRANSACTION;
    DELETE FROM customers WHERE customer_id = 23;
    SELECT IF(fk_blocked,
              'PASS: FK blocked deletion of a customer referenced by a report',
              'FAIL: deletion was not blocked') AS delete_anomaly_result;
    ROLLBACK;
END//
DELIMITER ;

CALL demonstrate_delete_protection();
DROP PROCEDURE demonstrate_delete_protection;

SELECT IF(EXISTS(SELECT 1 FROM customers WHERE customer_id = 23),
          'PASS: customer 23 is preserved', 'FAIL') AS customer_preserved;
