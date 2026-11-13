#!/usr/bin/env bash
set -euo pipefail

lab_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$lab_dir"

docker exec -i normalization-1-mysql \
  mysql -uroot --default-character-set=utf8mb4 --table \
  < sql/02_demonstrate_anomalies.sql | tee evidence/02_anomalies.txt

docker exec normalization-1-mysql \
  mysqldump -uroot --default-character-set=utf8mb4 \
  --no-tablespaces --databases normalization_1 \
  > dump_before_normalization.sql

printf 'PASS: three anomalies demonstrated and pre-normalization dump saved.\n'
