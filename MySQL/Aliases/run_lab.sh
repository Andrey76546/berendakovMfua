#!/usr/bin/env bash

set -euo pipefail

container_name="mysql_alias"
volume_name="mysql_alias_data"

if docker ps -a --format '{{.Names}}' | grep -Fxq "$container_name"; then
  echo "Контейнер $container_name уже существует; запуск остановлен без удаления данных." >&2
  exit 1
fi

if docker volume ls --format '{{.Name}}' | grep -Fxq "$volume_name"; then
  echo "Volume $volume_name уже существует; запуск остановлен без удаления данных." >&2
  exit 1
fi

echo "[1/8] Сборка образа MySQL 8.0 с безопасными правами my.cnf"
docker build --tag mysql-alias:8.0 .

echo "[2/8] Запуск изолированного MySQL 8.0"
docker run --name "$container_name" \
  -e MYSQL_ROOT_PASSWORD=123 \
  -e LANG=C.UTF-8 \
  -e MYSQL_INITDB_SKIP_TZINFO=1 \
  -v "$volume_name:/var/lib/mysql" \
  -d mysql-alias:8.0

echo "[3/8] Ожидание готовности MySQL"
for attempt in $(seq 1 90); do
  if docker exec "$container_name" mysqladmin ping -uroot -p123 --silent >/dev/null 2>&1; then
    break
  fi
  if [[ "$attempt" -eq 90 ]]; then
    echo "MySQL не запустился за отведённое время." >&2
    exit 1
  fi
  sleep 1
done

echo "[4/8] Очистка стартового general_log"
docker exec -u mysql "$container_name" sh -c ': > /var/lib/mysql/general.log'

echo "[5/8] Создание alias_db, таблиц и данных"
docker exec -i "$container_name" \
  mysql --default-character-set=utf8mb4 -uroot -p123 \
  < setup.sql | tee setup-output.txt

echo "[6/8] Выполнение запросов с алиасами"
docker exec -i "$container_name" \
  mysql --default-character-set=utf8mb4 -uroot -p123 \
  < queries.sql | tee queries-output.txt

echo "[7/8] Экспорт отфильтрованного журнала действий"
docker exec -i "$container_name" mysql -uroot -p123 \
  -e 'SET GLOBAL general_log=OFF;'
MSYS_NO_PATHCONV=1 docker exec "$container_name" cat /var/lib/mysql/general.log \
  | grep -E 'Query[[:space:]]+(CREATE|INSERT|SELECT|UPDATE|DELETE|ALTER|DROP|RENAME|DESCRIBE|EXPLAIN|SHOW DATABASES|SHOW TABLES|SHOW FULL TABLES|SHOW CREATE|SHOW VARIABLES LIKE)' \
  | grep -v -E 'INSERT INTO help_|INSERT INTO time_zone|INSERT INTO mysql\.|SELECT \* FROM mysql\.general_log' \
  > my_actions.log

echo "[8/8] Создание настоящего дампа alias_db"
docker exec -e MYSQL_PWD=123 "$container_name" \
  mysqldump -uroot --set-gtid-purged=OFF --single-transaction alias_db \
  > alias_dump.sql

echo "Лабораторная выполнена: SQL, лог и дамп сохранены."
