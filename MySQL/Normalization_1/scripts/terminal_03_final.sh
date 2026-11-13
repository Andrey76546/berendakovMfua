#!/usr/bin/env bash
set -euo pipefail
export PATH="/usr/bin:/bin:$PATH"

lab_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$lab_dir"

clear 2>/dev/null || true
printf 'Normalization_1 | final data and verification\n'
printf '$ mysql < sql/08_final_evidence.sql\n\n'
docker exec -i normalization-1-mysql \
  mysql -uroot --default-character-set=utf8mb4 --table \
  < sql/08_final_evidence.sql | tee evidence/08_final_evidence.txt
printf '\nSUCCESS: every final check returned PASS.\n'
printf 'Screenshot 3 is ready. Press Enter only after it is captured.\n'
read -r
