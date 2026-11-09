USE shop;

SHOW TABLES;
SELECT * FROM products1;
SELECT * FROM products2;

SELECT
  (SELECT COUNT(*) FROM products1) AS products1_rows,
  (SELECT COUNT(*) FROM products2) AS products2_rows;
