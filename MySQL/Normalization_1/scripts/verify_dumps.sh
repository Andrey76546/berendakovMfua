#!/usr/bin/env bash
set -euo pipefail

lab_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$lab_dir"

check_container='normalization-1-restore-check'

if docker inspect "$check_container" >/dev/null 2>&1; then
  printf 'Refusing to reuse existing container: %s\n' "$check_container" >&2
  exit 1
fi

docker run --name "$check_container" \
  --label lab=Normalization_1_dump_check \
  -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
  -d mysql:8.4 \
  --character-set-server=utf8mb4 \
  --collation-server=utf8mb4_0900_ai_ci >/dev/null

cleanup() {
  docker rm -f "$check_container" >/dev/null
}
trap cleanup EXIT

until docker exec "$check_container" mysqladmin -uroot ping --silent >/dev/null 2>&1; do
  sleep 2
done

docker exec -i "$check_container" mysql -uroot < dump_before_normalization.sql
docker exec "$check_container" mysql -uroot --table -e "
  SELECT COUNT(*) AS before_rows,
         SUM(price * quantity) AS before_total
  FROM normalization_1.sales_unnormalized_2;"

docker exec "$check_container" mysql -uroot -e "DROP DATABASE normalization_1;"

docker exec -i "$check_container" mysql -uroot < dump_after_normalization.sql
docker exec "$check_container" mysql -uroot --table -e "
  SELECT (SELECT COUNT(*) FROM normalization_1.customers) AS customers,
         (SELECT COUNT(*) FROM normalization_1.products) AS products,
         (SELECT COUNT(*) FROM normalization_1.reports) AS reports,
         (SELECT COUNT(*) FROM normalization_1.report_items) AS report_items,
         (SELECT COUNT(*) FROM normalization_1.sales_unnormalized_2_archived) AS archived_rows,
         (SELECT SUM(p.price * ri.quantity)
          FROM normalization_1.report_items AS ri
          JOIN normalization_1.products AS p ON p.product_id = ri.product_id) AS after_total;"

printf 'PASS: both dumps restore successfully in an isolated temporary container.\n'
