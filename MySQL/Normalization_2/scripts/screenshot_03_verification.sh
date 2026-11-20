#!/usr/bin/env bash
set -euo pipefail
clear
printf 'NORMALIZATION #2 — ИТОГОВАЯ ПРОВЕРКА\n'
printf 'Контейнер: normalization-2-mysql | База: sales_norm_2\n\n'
docker exec normalization-2-mysql mysql -uroot --default-character-set=utf8mb4 --table -e "source /lab/sql/05_final_verification.sql"
printf '\nПроверка завершена: количества, суммы, JOIN и внешние связи.\n'
printf '\033]0;Normalization 2 - Verification READY\007'
read -r
