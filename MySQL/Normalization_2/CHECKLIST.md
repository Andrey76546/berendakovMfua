# CHECKLIST — Normalization №2

Сверка выполнена по [оригинальному заданию преподавателя](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Normalization_2.md). Статус «выполнено» указан только там, где есть реальный файл и фактическое доказательство MySQL/CLI.

| Требование | Что реально сделано | Файл результата | Запрос или доказательство | Статус |
|---|---|---|---|---|
| Работать в новой папке существующего проекта | Создана только `MySQL/Normalization_2`; старые лабораторные не редактировались | [README.md](README.md) | `git diff -- MySQL/Normalization MySQL/Normalization_1` — без новых изменений | Выполнено |
| Прочитать оригинальную инструкцию и использовать практический набор | Использованы таблица `sales_unnormalized` и все 10 строк из практической части | [sql/00_create_source.sql](sql/00_create_source.sql) | `INSERT ...` → `10 rows affected` | Выполнено |
| Отдельная база и безопасная изоляция | Созданы контейнер `normalization-2-mysql` с `network=none` и БД `sales_norm_2` | [evidence/08_artifact_manifest.txt](evidence/08_artifact_manifest.txt) | `docker inspect`; запрос к `information_schema.SCHEMATA` | Выполнено |
| Создать исходную таблицу | Схема повторяет SQL преподавателя | [sql/00_create_source.sql](sql/00_create_source.sql) | `CREATE TABLE sales_unnormalized` → `Query OK` | Выполнено |
| Вставить без изменений 10 строк | Вставлены даты, имена, города, товары, цены и количества из задания | [evidence/01_source_creation.txt](evidence/01_source_creation.txt) | `SELECT * ... ORDER BY sale_id, product_id`; `COUNT(*)=10` | Выполнено |
| Показать аномалию обновления | Изменение одной копии города породило 2 разных города клиента 101; выполнен `ROLLBACK` | [evidence/02_anomalies.txt](evidence/02_anomalies.txt) | `COUNT(DISTINCT client_city)=2` | Выполнено |
| Показать аномалию вставки | Клиент без продажи потребовал неполную строку с полями продажи/товара `NULL`; выполнен `ROLLBACK` | [evidence/02_anomalies.txt](evidence/02_anomalies.txt) | `malformed_rows_required_for_client_without_sale=1` | Выполнено |
| Показать аномалию удаления | Удаление продаж клиента 102 убрало все его строки; выполнен `ROLLBACK` | [evidence/02_anomalies.txt](evidence/02_anomalies.txt) | до `3`, после `0`; затем исходные `10` и `80000.00` | Выполнено |
| Создать `clients` | PK `client_id`, обязательные имя и город | [sql/02_create_3nf.sql](sql/02_create_3nf.sql) | `CREATE TABLE clients` → `Query OK` | Выполнено |
| Создать `products` | PK `product_id`, `CHECK (unit_price >= 0)` | [sql/02_create_3nf.sql](sql/02_create_3nf.sql) | `CREATE TABLE products` → `Query OK` | Выполнено |
| Создать `sales` | PK `sale_id`, FK `client_id → clients` | [sql/02_create_3nf.sql](sql/02_create_3nf.sql) | `fk_sales_client` найден в `information_schema` | Выполнено |
| Создать `sale_items` | Составной PK, два FK, положительное количество | [sql/02_create_3nf.sql](sql/02_create_3nf.sql) | `fk_sale_items_sale`, `fk_sale_items_product`, CHECK | Выполнено |
| Перенести данные через `INSERT ... SELECT` | Четыре вставки-выборки выполнены одной транзакцией | [sql/03_migrate.sql](sql/03_migrate.sql), [evidence/04_migration.txt](evidence/04_migration.txt) | MySQL: `3`, `5`, `6`, `10 rows affected`, `COMMIT` | Выполнено |
| Проверить всех клиентов | Выведены 3 клиента | [evidence/05_full_verification.txt](evidence/05_full_verification.txt) | `SELECT * FROM clients` | Выполнено |
| Проверить все товары | Выведены 5 товаров | [evidence/05_full_verification.txt](evidence/05_full_verification.txt) | `SELECT * FROM products` | Выполнено |
| Проверить все продажи | Выведены 6 продаж | [evidence/05_full_verification.txt](evidence/05_full_verification.txt) | `SELECT * FROM sales` | Выполнено |
| Проверить все позиции | Выведены 10 позиций | [evidence/05_full_verification.txt](evidence/05_full_verification.txt) | `SELECT * FROM sale_items` | Выполнено |
| Проверить PK/FK | Получены 4 PK, 3 FK и 2 CHECK; сиротских строк нет | [evidence/05_full_verification.txt](evidence/05_full_verification.txt) | `information_schema.table_constraints`; проверки сирот `0/0/0` | Выполнено |
| Сохранить общую сумму | До и после — `80000.00` | [evidence/06_final_verification.txt](evidence/06_final_verification.txt) | две независимые `SUM(...)` | Выполнено |
| Восстановить исходные строки через JOIN | Восстановлено 10 строк, расхождений 0 | [evidence/05_full_verification.txt](evidence/05_full_verification.txt) | JOIN четырёх таблиц; `mismatched_rows=0` | Выполнено |
| Доказать устранение аномалий | Обновление в одном месте, самостоятельная вставка клиента, удаление продажи без потери клиента | [sql/04_verify.sql](sql/04_verify.sql) | три транзакционных теста с `ROLLBACK` | Выполнено |
| Сделать дамп до нормализации | Настоящий `mysqldump`, 3576 байт; успешно восстановлен в чистом контейнере | [dumps/before_normalization.sql](dumps/before_normalization.sql), [evidence/10_dump_restore_check.txt](evidence/10_dump_restore_check.txt) | 1 таблица, 10 строк, сумма `80000.00` после восстановления | Выполнено |
| Сделать дамп после нормализации | Настоящий `mysqldump`, 7596 байт; успешно восстановлен в чистом контейнере | [dumps/after_normalization.sql](dumps/after_normalization.sql), [evidence/10_dump_restore_check.txt](evidence/10_dump_restore_check.txt) | 5 таблиц, количества `10/3/5/6/10`, обе суммы `80000.00` | Выполнено |
| Вести лог только своих действий | Записан stdout/stderr реальных MySQL-сеансов `-vvv`; General Log не включался | [logs/mysql_actions.log](logs/mysql_actions.log) | SQL-команды, `Query OK`, выборки, `COMMIT`/`ROLLBACK` | Выполнено |
| Сделать ровно 3 новых скриншота | Созданы три PNG реальных Git Bash-окон, новых кадров после этого нет | [screenshots/](screenshots/) | манифест содержит ровно 3 PNG и SHA-256 | Выполнено |
| Описать ошибки инструкции | Зафиксированы `orders_bad`/`sales_unnormalized`, nullable-вставка и зависимости по ID | [README.md](README.md#12-обнаруженные-расхождения-в-инструкции) | отдельный раздел без молчаливой подмены | Выполнено |
| Сохранить исходную информацию | Таблица оставлена как проверочный эталон после дампа и сверки | [README.md](README.md#9-дампы-до-и-после-нормализации) | финально `source_rows=10`, сумма `80000.00` | Выполнено |
| Проверить инструменты и артефакты | Зафиксированы версии, размеры и SHA-256 | [evidence/08_artifact_manifest.txt](evidence/08_artifact_manifest.txt), [evidence/09_tool_versions.txt](evidence/09_tool_versions.txt) | Docker 29.7.2, MySQL 8.4.11, VS Code 1.146.0, Git Bash 5.3.15 | Выполнено |

## Итоговые контрольные значения

```text
source_rows=10
clients=3
products=5
sales=6
sale_items=10
source_total=80000.00
normalized_total=80000.00
reconstructed_rows=10
mismatched_rows=0
orphans=0/0/0
```
