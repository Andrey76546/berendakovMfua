-- Учебная база для лабораторной работы по MySQL VIEW.
-- Скрипт создаёт исходные таблицы, тестовые данные и итоговый набор VIEW.

CREATE DATABASE IF NOT EXISTS view_lab
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE view_lab;

CREATE TABLE customers (
    id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(120) NOT NULL UNIQUE,
    city       VARCHAR(60) NOT NULL,
    status     ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
    created_at DATE NOT NULL
) ENGINE = InnoDB;

CREATE TABLE orders (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id INT UNSIGNED NOT NULL,
    order_date  DATE NOT NULL,
    amount      DECIMAL(10, 2) NOT NULL,
    status      ENUM('new', 'paid', 'shipped', 'cancelled') NOT NULL,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    INDEX idx_orders_customer_id (customer_id),
    INDEX idx_orders_status (status)
) ENGINE = InnoDB;

INSERT INTO customers (name, email, city, status, created_at) VALUES
('Анна Смирнова',    'anna@example.test',    'Москва',         'active',   '2025-09-01'),
('Борис Волков',     'boris@example.test',   'Санкт-Петербург','active',   '2025-09-03'),
('Виктория Орлова',  'viktoria@example.test','Москва',         'inactive', '2025-09-05'),
('Глеб Морозов',     'gleb@example.test',    'Казань',         'active',   '2025-09-08'),
('Дарья Соколова',   'daria@example.test',   'Санкт-Петербург','active',   '2025-09-10'),
('Егор Павлов',      'egor@example.test',    'Москва',         'active',   '2025-09-12');

INSERT INTO orders (customer_id, order_date, amount, status) VALUES
(1, '2025-10-01', 1250.50, 'paid'),
(1, '2025-10-12',  480.00, 'shipped'),
(2, '2025-10-03', 2100.00, 'paid'),
(2, '2025-10-20',  350.00, 'cancelled'),
(3, '2025-10-05',  875.00, 'shipped'),
(5, '2025-10-08', 3200.00, 'paid'),
(6, '2025-10-11',  600.00, 'new'),
(6, '2025-10-18',  950.00, 'paid');

CREATE ALGORITHM = MERGE
SQL SECURITY DEFINER
VIEW moscow_customers AS
SELECT id, name, email, city, created_at
FROM customers
WHERE city = 'Москва'
WITH CASCADED CHECK OPTION;

CREATE ALGORITHM = UNDEFINED
SQL SECURITY DEFINER
VIEW customer_order_summary AS
SELECT
    c.id AS customer_id,
    c.name,
    c.city,
    COUNT(o.id) AS order_count,
    COALESCE(SUM(o.amount), 0.00) AS total_amount
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.id
GROUP BY c.id, c.name, c.city;

CREATE ALGORITHM = MERGE
SQL SECURITY DEFINER
VIEW active_customers AS
SELECT id, name, email, city, created_at
FROM customers
WHERE status = 'active';

CREATE ALGORITHM = MERGE
SQL SECURITY DEFINER
VIEW large_orders AS
SELECT id, customer_id, order_date, amount, status
FROM orders
WHERE amount >= 1000.00;

CREATE ALGORITHM = MERGE
SQL SECURITY DEFINER
VIEW public_customers AS
SELECT id, name, city, status
FROM customers;
