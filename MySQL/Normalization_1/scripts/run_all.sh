#!/usr/bin/env bash
set -euo pipefail

lab_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$lab_dir"

container='normalization-1-mysql'

if ! docker inspect "$container" >/dev/null 2>&1; then
  docker run --name "$container" \
    --label lab=Normalization_1 \
    -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
    -d mysql:8.4 \
    --character-set-server=utf8mb4 \
    --collation-server=utf8mb4_0900_ai_ci
else
  docker start "$container" >/dev/null
fi

until docker exec "$container" mysqladmin -uroot ping --silent >/dev/null 2>&1; do
  sleep 2
done

docker exec -i "$container" mysql -uroot < sql/00_enable_log.sql
docker exec -i "$container" mysql -uroot --default-character-set=utf8mb4 < sql/01_create_source.sql
bash ./scripts/run_before_3nf.sh
docker exec -i "$container" mysql -uroot --default-character-set=utf8mb4 < sql/03_create_3nf.sql
bash ./scripts/run_after_3nf.sh
docker exec -i "$container" mysql -uroot --default-character-set=utf8mb4 < sql/08_final_evidence.sql
bash ./scripts/export_log.sh

printf 'Normalization_1 completed successfully.\n'
