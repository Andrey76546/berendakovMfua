DROP DATABASE IF EXISTS normalization_1;
CREATE DATABASE normalization_1
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE normalization_1;

CREATE TABLE sales_unnormalized_2 (
    report_id     INT,
    report_date   DATE,
    customer_id   INT,
    customer_name VARCHAR(100),
    product_id    INT,
    product_name  VARCHAR(100),
    price         DECIMAL(10,2),
    quantity      INT
);

INSERT INTO sales_unnormalized_2 VALUES
    (1101, '2026-03-05', 12, 'Дания',   101, 'Дыни',      800, 1100),
    (1101, '2026-03-05', 12, 'Дания',   102, 'Клубника',  150,  300),
    (1102, '2026-03-07', 23, 'Испания', 103, 'Яблоки',    120, 1700),
    (1103, '2026-03-08', 25, 'Албания', 104, 'Лимоны',    200,  500),
    (1104, '2026-03-10', 12, 'Дания',   101, 'Дыни',      800, 2500),
    (1105, '2026-03-12', 25, 'Албания', 103, 'Яблоки',    120, 2000),
    (1105, '2026-03-12', 25, 'Албания', 104, 'Лимоны',    200,  700);

SHOW TABLES;
SELECT *
FROM sales_unnormalized_2
ORDER BY report_id, product_id;

SELECT COUNT(*) AS source_rows,
       COUNT(DISTINCT report_id) AS source_reports,
       COUNT(DISTINCT customer_id) AS source_customers,
       COUNT(DISTINCT product_id) AS source_products,
       SUM(price * quantity) AS source_total
FROM sales_unnormalized_2;
