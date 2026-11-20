-- Этап 1. Отдельная база и исходная таблица из практической части задания.
CREATE DATABASE sales_norm_2
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE sales_norm_2;

CREATE TABLE sales_unnormalized (
    sale_id       INT,
    sale_date     DATE,
    client_id     INT,
    client_name   VARCHAR(100),
    client_city   VARCHAR(100),
    product_id    INT,
    product_name  VARCHAR(100),
    unit_price    DECIMAL(10,2),
    quantity      INT
);

INSERT INTO sales_unnormalized VALUES
(5001, '2026-11-01', 101, 'Иванов Иван',     'Москва',           201, 'Монитор',    15000.00, 2),
(5001, '2026-11-01', 101, 'Иванов Иван',     'Москва',           202, 'Клавиатура',  2000.00, 1),
(5002, '2026-11-02', 102, 'Петрова Мария',   'Санкт-Петербург', 203, 'Мышь',        1000.00, 3),
(5002, '2026-11-02', 102, 'Петрова Мария',   'Санкт-Петербург', 204, 'Наушники',    3500.00, 1),
(5003, '2026-11-03', 101, 'Иванов Иван',     'Москва',           205, 'Колонки',     2500.00, 2),
(5004, '2026-11-04', 103, 'Сидоров Алексей', 'Казань',           202, 'Клавиатура',  2000.00, 5),
(5004, '2026-11-04', 103, 'Сидоров Алексей', 'Казань',           203, 'Мышь',        1000.00, 2),
(5005, '2026-11-05', 102, 'Петрова Мария',   'Санкт-Петербург', 201, 'Монитор',    15000.00, 1),
(5006, '2026-11-06', 103, 'Сидоров Алексей', 'Казань',           204, 'Наушники',    3500.00, 2),
(5006, '2026-11-06', 103, 'Сидоров Алексей', 'Казань',           205, 'Колонки',     2500.00, 1);

SELECT COUNT(*) AS source_rows,
       SUM(unit_price * quantity) AS source_total
FROM sales_unnormalized;

SELECT *
FROM sales_unnormalized
ORDER BY sale_id, product_id;
