#!/usr/bin/env bash

set -euo pipefail

: "${MYSQL_ROOT_PASSWORD:?Задайте MYSQL_ROOT_PASSWORD в окружении}"

MYSQL=(docker exec -e "MYSQL_PWD=${MYSQL_ROOT_PASSWORD}" products-mysql mysql --no-defaults --default-character-set=utf8mb4 -uroot -t)

case "${1:-}" in
  database)
    echo '$ docker ps --filter name=products-mysql'
    docker ps --filter name=products-mysql --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
    echo
    echo '$ docker exec ... mysql -e "SHOW DATABASES; USE shop; SHOW TABLES; SELECT * FROM products1; SELECT * FROM products2;"'
    "${MYSQL[@]}" -e 'SHOW DATABASES LIKE "shop"; USE shop; SHOW TABLES; SELECT * FROM products1; SELECT * FROM products2;'
    ;;

  queries)
    echo '$ SELECT name FROM products1 UNION SELECT name FROM products2;'
    "${MYSQL[@]}" shop -e 'SELECT name FROM products1 UNION SELECT name FROM products2;'
    echo '$ SELECT name, price FROM products1 EXCEPT SELECT name, price FROM products2;'
    "${MYSQL[@]}" shop -e 'SELECT name, price FROM products1 EXCEPT SELECT name, price FROM products2;'
    echo '$ SELECT name, price FROM products1 INTERSECT SELECT name, price FROM products2;'
    "${MYSQL[@]}" shop -e 'SELECT name, price FROM products1 INTERSECT SELECT name, price FROM products2;'
    echo '$ SELECT t1.name, t1.price AS price1, t2.price AS price2 FROM products1 t1 JOIN products2 t2 ON t1.name=t2.name;'
    "${MYSQL[@]}" shop -e 'SELECT t1.name, t1.price AS price1, t2.price AS price2 FROM products1 t1 JOIN products2 t2 ON t1.name = t2.name;'
    ;;

  restore)
    echo '$ test -s dump.sql && echo "dump.sql: файл существует и не пуст"'
    test -s dump.sql && echo 'dump.sql: файл существует и не пуст'
    echo '$ docker exec ... mysql -e "DROP DATABASE shop; CREATE DATABASE shop ...;"'
    "${MYSQL[@]}" -e 'DROP DATABASE shop; CREATE DATABASE shop CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'
    echo '$ docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" products-mysql mysql -uroot --force shop < dump.sql'
    docker exec -i -e "MYSQL_PWD=${MYSQL_ROOT_PASSWORD}" products-mysql mysql --no-defaults -uroot --force shop < dump.sql 2>/dev/null
    echo '$ docker exec ... mysql shop -e "SHOW TABLES; SELECT * ...; SELECT COUNT(*) ...;"'
    "${MYSQL[@]}" shop -e 'SHOW TABLES; SELECT * FROM products1; SELECT * FROM products2; SELECT (SELECT COUNT(*) FROM products1) AS products1_rows, (SELECT COUNT(*) FROM products2) AS products2_rows;'
    ;;

  *)
    echo "Использование: bash terminal-demo.sh {database|queries|restore}" >&2
    exit 2
    ;;
esac
