#!/usr/bin/env bash
set -euo pipefail
clear
printf 'NORMALIZATION #2 — ЭТАПЫ 3–5: ТАБЛИЦЫ 3NF И ДАННЫЕ\n'
printf 'Контейнер: normalization-2-mysql | База: sales_norm_2\n\n'
docker exec normalization-2-mysql mysql -uroot --default-character-set=utf8mb4 --table -e "
USE sales_norm_2;
SHOW TABLES;
SELECT 'clients' AS table_name; SELECT * FROM clients ORDER BY client_id;
SELECT 'products' AS table_name; SELECT * FROM products ORDER BY product_id;
SELECT 'sales' AS table_name; SELECT * FROM sales ORDER BY sale_id;
SELECT 'sale_items' AS table_name; SELECT * FROM sale_items ORDER BY sale_id, product_id;
"
printf '\nЧетыре нормализованные таблицы выведены из MySQL.\n'
printf '\033]0;Normalization 2 - 3NF READY\007'
read -r
