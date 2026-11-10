#!/usr/bin/env bash

set -euo pipefail

container_name="mysql_alias"
check_database="alias_restore_check"

echo "=== Версия, настройки и данные рабочей базы ==="
docker exec "$container_name" mysql --default-character-set=utf8mb4 -uroot -p123 \
  -e "SELECT VERSION() AS mysql_version; SHOW VARIABLES LIKE 'general_log_file'; SHOW VARIABLES LIKE 'log_output'; USE alias_db; SELECT (SELECT COUNT(*) FROM customers) AS customers_count, (SELECT COUNT(*) FROM orders) AS orders_count, (SELECT COUNT(*) FROM employees) AS employees_count;"

echo "=== Проверка восстановления alias_dump.sql ==="
docker exec "$container_name" mysql -uroot -p123 \
  -e "DROP DATABASE IF EXISTS ${check_database}; CREATE DATABASE ${check_database} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
docker exec -i "$container_name" mysql --default-character-set=utf8mb4 -uroot -p123 "$check_database" \
  < alias_dump.sql
docker exec "$container_name" mysql --default-character-set=utf8mb4 -uroot -p123 \
  -e "USE ${check_database}; SELECT (SELECT COUNT(*) FROM customers) AS restored_customers, (SELECT COUNT(*) FROM orders) AS restored_orders, (SELECT COUNT(*) FROM employees) AS restored_employees;"
docker exec "$container_name" mysql -uroot -p123 \
  -e "DROP DATABASE ${check_database};"

echo "Дамп успешно восстановлен и проверен; временная база удалена."
