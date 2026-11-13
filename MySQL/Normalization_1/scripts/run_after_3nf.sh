#!/usr/bin/env bash
set -euo pipefail

lab_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$lab_dir"

for stage in 04_migrate 05_verify 06_anomalies_resolved 07_archive_source; do
  docker exec -i normalization-1-mysql \
    mysql -uroot --default-character-set=utf8mb4 --table \
    < "sql/${stage}.sql" | tee "evidence/${stage}.txt"
done

docker exec normalization-1-mysql \
  mysqldump -uroot --default-character-set=utf8mb4 \
  --no-tablespaces --routines --databases normalization_1 \
  > dump_after_normalization.sql

printf 'PASS: migration, verification, anomaly tests, archive and final dump completed.\n'
