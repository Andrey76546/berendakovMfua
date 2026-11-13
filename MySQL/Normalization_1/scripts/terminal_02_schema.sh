#!/usr/bin/env bash
set -euo pipefail
export PATH="/usr/bin:/bin:$PATH"

lab_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$lab_dir"

clear 2>/dev/null || true
printf 'Normalization_1 | create and inspect four 3NF tables\n'
printf '$ mysql < sql/03_create_3nf.sql\n\n'
docker exec -i normalization-1-mysql \
  mysql -uroot --default-character-set=utf8mb4 --table \
  < sql/03_create_3nf.sql | tee evidence/03_create_3nf.txt
printf '\nPASS: customers, products, reports and report_items created with PK/FK constraints.\n'
printf 'Screenshot 2 is ready. Press Enter only after it is captured.\n'
read -r
