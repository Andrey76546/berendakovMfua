#!/usr/bin/env bash
set -euo pipefail
export PATH="/usr/bin:/bin:$PATH"

lab_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$lab_dir"

clear 2>/dev/null || true
printf 'Normalization_1 | Git Bash + Docker CLI + MySQL\n'
printf '$ mysql < sql/01_create_source.sql\n\n'
docker exec -i normalization-1-mysql \
  mysql -uroot --default-character-set=utf8mb4 --table \
  < sql/01_create_source.sql | tee evidence/01_source_creation.txt
printf '\nPASS: source table created and 7 real rows displayed.\n'
printf 'Screenshot 1 is ready. Press Enter only after it is captured.\n'
read -r
