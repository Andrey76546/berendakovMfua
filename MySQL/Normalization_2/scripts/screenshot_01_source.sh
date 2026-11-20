#!/usr/bin/env bash
set -euo pipefail
clear
printf 'NORMALIZATION #2 — ЭТАП 1: ИСХОДНАЯ ТАБЛИЦА\n'
printf 'Контейнер: normalization-2-mysql | База: sales_norm_2\n\n'
docker exec normalization-2-mysql mysql -uroot --default-character-set=utf8mb4 --table -e "
USE sales_norm_2;
DESCRIBE sales_unnormalized;
SELECT COUNT(*) AS source_rows,
       SUM(unit_price * quantity) AS source_total
FROM sales_unnormalized;
SELECT * FROM sales_unnormalized ORDER BY sale_id, product_id;
"
printf '\nРеальный запрос MySQL завершён успешно.\n'
printf '\033]0;Normalization 2 - Source READY\007'
read -r
