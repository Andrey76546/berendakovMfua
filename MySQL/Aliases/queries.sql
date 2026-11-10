USE alias_db;

-- 1. Алиасы таблиц в JOIN.
SELECT c.name, o.order_date, o.amount
FROM customers AS c
JOIN orders AS o ON c.id = o.customer_id;

-- 2. Самосоединение: алиасы разделяют сотрудника и руководителя.
SELECT e.name AS employee, m.name AS manager
FROM employees AS e
JOIN employees AS m ON e.manager_id = m.id;

-- 3. Алиасы устраняют неоднозначность одинаковых имён столбцов.
SELECT c.id AS customer_id, o.id AS order_id
FROM customers AS c
JOIN orders AS o ON c.id = o.customer_id;

-- 4. Производная таблица обязательно получает алиас.
SELECT *
FROM (
    SELECT customer_id, SUM(amount) AS total
    FROM orders
    GROUP BY customer_id
) AS t;

-- 5. Алиасы столбцов делают заголовки результата понятными.
SELECT name AS customer_name,
       email AS contact_email
FROM customers;

-- 6. GROUP BY, HAVING и ORDER BY с алиасами агрегатов.
SELECT customer_id,
       COUNT(*) AS order_count,
       SUM(amount) AS total_amount
FROM orders
GROUP BY customer_id
HAVING total_amount > 1000
ORDER BY total_amount DESC;

-- 7. Алиас вычисляемого столбца доступен в ORDER BY.
SELECT id, amount * 2 AS double_amount
FROM orders
ORDER BY double_amount DESC;

-- 8. В WHERE повторяется выражение: алиас SELECT там ещё недоступен.
SELECT id, amount * 2 AS double_amount
FROM orders
WHERE amount * 2 > 1000
ORDER BY double_amount DESC;

-- 9. Алиасы во внешнем запросе и подзапросе в FROM.
SELECT c.name AS customer_name, totals.total AS total_amount
FROM customers AS c
JOIN (
    SELECT customer_id, SUM(amount) AS total
    FROM orders
    GROUP BY customer_id
) AS totals ON c.id = totals.customer_id
WHERE totals.total > 2000
ORDER BY total_amount DESC;

-- 10. Коррелированный скалярный подзапрос.
SELECT c.name AS customer_name,
       (
           SELECT COUNT(*)
           FROM orders AS o
           WHERE o.customer_id = c.id
       ) AS order_count
FROM customers AS c
ORDER BY c.id;

-- 11. JOIN, алиасы таблиц и столбцов, фильтрация и сортировка.
SELECT c.name AS customer,
       o.order_date,
       o.amount,
       o.amount * 2 AS double_amount
FROM customers AS c
JOIN orders AS o ON c.id = o.customer_id
WHERE o.status = 'paid'
ORDER BY double_amount DESC;

-- 12. Итоговый агрегирующий запрос с алиасами.
SELECT c.name AS customer_name,
       COUNT(o.id) AS order_count,
       SUM(o.amount) AS total_amount
FROM customers AS c
JOIN orders AS o ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY total_amount DESC;
