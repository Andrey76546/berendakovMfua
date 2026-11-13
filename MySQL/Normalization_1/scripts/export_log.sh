#!/usr/bin/env bash
set -euo pipefail

lab_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$lab_dir"

docker exec normalization-1-mysql \
  mysql -uroot --default-character-set=utf8mb4 \
  -e "SET GLOBAL general_log = 'OFF';"

docker exec normalization-1-mysql \
  mysql -uroot --default-character-set=utf8mb4 --batch --skip-column-names \
  -e "SELECT CONCAT(DATE_FORMAT(event_time, '%Y-%m-%d %H:%i:%s.%f'),
                    CHAR(9), 'thread=', thread_id,
                    CHAR(9), argument)
      FROM mysql.general_log
      WHERE command_type = 'Query'
        AND argument NOT LIKE '%mysql.general_log%'
      ORDER BY event_time" \
  > my_actions.log

printf 'PASS: MySQL query log exported to my_actions.log.\n'
