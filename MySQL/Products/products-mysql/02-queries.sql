USE shop;

-- 1. Выборка: товары из products1 дороже 150.
SELECT * FROM products1 WHERE price > 150;

-- 2. Проекция: только названия товаров из products1.
SELECT name FROM products1;

-- 3. Объединение без дубликатов.
SELECT name FROM products1
UNION
SELECT name FROM products2;

-- 4. Разность множеств.
SELECT name, price FROM products1
EXCEPT
SELECT name, price FROM products2;

-- 5. Пересечение множеств.
SELECT name, price FROM products1
INTERSECT
SELECT name, price FROM products2;

-- 6. Декартово произведение: 4 x 4 = 16 строк.
SELECT t1.name AS name1, t1.price AS price1,
       t2.name AS name2, t2.price AS price2
FROM products1 t1
CROSS JOIN products2 t2;

-- 7. Внутреннее соединение по названию товара.
SELECT t1.name, t1.price AS price1, t2.price AS price2
FROM products1 t1
JOIN products2 t2 ON t1.name = t2.name;

-- Дополнительный запрос из задания: левое соединение.
SELECT t1.name, t1.price AS price1, t2.price AS price2
FROM products1 t1
LEFT JOIN products2 t2 ON t1.name = t2.name;
