# Основные SQL-операции: `products1` и `products2`

## Цель работы

Создать в MySQL базу данных `shop` с двумя таблицами товаров, выполнить основные операции реляционной алгебры средствами SQL, создать настоящий дамп базы, удалить исходную базу и восстановить её из дампа с проверкой данных.

Задание преподавателя: [Products.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Products.md).

Работа выполнена в VS Code через Git Bash, Docker и MySQL. Использован отдельный контейнер `products-mysql` и отдельный Docker-том `products_mysql_data`, поэтому другие лабораторные и их данные не затрагиваются. Глобальная очистка Docker-контейнеров и томов не выполнялась.

## Файлы проекта

- `my.cnf` — настройки MySQL для корректной работы с UTF-8;
- `01-create.sql` — создание базы и таблиц, заполнение и первичная проверка;
- `02-queries.sql` — все запросы из задания;
- `03-verify.sql` — проверка восстановленных таблиц и количества строк;
- `terminal-demo.sh` — воспроизводимый текстовый вывод основных проверок;
- `dump.sql` — реальный дамп базы `shop`, созданный программой `mysqldump`;

Скриншоты в текущей версии работы отсутствуют по требованию владельца репозитория. Все доказательства выполнения приведены ниже в виде команд, фактических текстовых результатов и контрольной суммы.

## 1. Запуск MySQL в Docker

В Git Bash создан рабочий каталог и из него запущен отдельный контейнер MySQL:

```bash
mkdir -p MySQL/Products/products-mysql
cd MySQL/Products/products-mysql

read -rsp "Учебный пароль MySQL: " MYSQL_ROOT_PASSWORD
echo
export MYSQL_ROOT_PASSWORD

docker run --name products-mysql \
  -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
  -e LANG=C.UTF-8 \
  -v products_mysql_data:/var/lib/mysql \
  -v "$(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf" \
  -d mysql:latest

docker ps --filter name=products-mysql
```

Пароль задаётся только в текущем сеансе терминала и не хранится в файлах репозитория.

## 2. Создание базы, таблиц и данных

База и таблицы созданы командами:

```sql
CREATE DATABASE shop
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE shop;

CREATE TABLE products1 (
    name  VARCHAR(100) NOT NULL,
    price INT NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE products2 (
    name  VARCHAR(100) NOT NULL,
    price INT NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Добавлены исходные данные:

```sql
INSERT INTO products1 (name, price) VALUES
  ('Дыни', 800),
  ('Клубника', 150),
  ('Яблоки', 120),
  ('Лимоны', 200);

INSERT INTO products2 (name, price) VALUES
  ('Дыни', 800),
  ('Клубника', 150),
  ('Каштаны', 200),
  ('Хурма', 350);
```

Скрипт выполнен из Git Bash:

```bash
docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" products-mysql \
  mysql --default-character-set=utf8mb4 -uroot < 01-create.sql
```

Результат проверки: в `shop` присутствуют таблицы `products1` и `products2`; в каждой таблице по четыре указанных в задании товара.

```text
Tables_in_shop
products1
products2

products1
Дыни       800
Клубника   150
Яблоки     120
Лимоны     200

products2
Дыни       800
Клубника   150
Каштаны    200
Хурма      350
```

## 3. Основные SQL-операции

### 3.1. Выборка

```sql
SELECT * FROM products1 WHERE price > 150;
```

Результат: `Дыни — 800`, `Лимоны — 200`.

### 3.2. Проекция

```sql
SELECT name FROM products1;
```

Результат: `Дыни`, `Клубника`, `Яблоки`, `Лимоны`.

### 3.3. Объединение

```sql
SELECT name FROM products1
UNION
SELECT name FROM products2;
```

Результат без дубликатов: `Дыни`, `Клубника`, `Яблоки`, `Лимоны`, `Каштаны`, `Хурма`.

### 3.4. Разность

```sql
SELECT name, price FROM products1
EXCEPT
SELECT name, price FROM products2;
```

Результат: `Яблоки — 120`, `Лимоны — 200`.

### 3.5. Пересечение

```sql
SELECT name, price FROM products1
INTERSECT
SELECT name, price FROM products2;
```

Результат: `Дыни — 800`, `Клубника — 150`.

### 3.6. Декартово произведение

```sql
SELECT t1.name AS name1, t1.price AS price1,
       t2.name AS name2, t2.price AS price2
FROM products1 t1
CROSS JOIN products2 t2;
```

Результат: все сочетания строк двух таблиц, всего `4 × 4 = 16` строк.

### 3.7. Соединение

```sql
SELECT t1.name, t1.price AS price1, t2.price AS price2
FROM products1 t1
JOIN products2 t2 ON t1.name = t2.name;
```

Результат: совпали `Дыни — 800 — 800` и `Клубника — 150 — 150`.

Дополнительно выполнен приведённый в задании `LEFT JOIN`:

```sql
SELECT t1.name, t1.price AS price1, t2.price AS price2
FROM products1 t1
LEFT JOIN products2 t2 ON t1.name = t2.name;
```

Он также вернул `Яблоки` и `Лимоны`, для которых цена из `products2` равна `NULL`.

Все запросы выполнены одной командой:

```bash
docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" products-mysql \
  mysql --default-character-set=utf8mb4 -uroot < 02-queries.sql
```

Операция деления для двух простых списков товаров не применяется: для неё необходима дополнительная таблица связи, например «поставщик — товар».

## 4. Создание дампа

Настоящий дамп создан утилитой `mysqldump` в обычном терминале хоста:

```bash
docker exec -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" products-mysql \
  mysqldump -uroot --default-character-set=utf8mb4 \
  --set-gtid-purged=OFF --single-transaction shop > dump.sql

test -s dump.sql && echo "dump.sql создан и не пуст"
```

Файл `dump.sql` содержит SQL-команды создания обеих таблиц и вставки восьми исходных строк.

## 5. Удаление и восстановление базы

Исходная учебная база удалена, отсутствие `shop` проверено:

```bash
docker exec -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" products-mysql \
  mysql -uroot -e "DROP DATABASE shop; SHOW DATABASES;"
```

Затем создана пустая база с нужной кодировкой и выполнен импорт дампа, как требует задание:

```bash
docker exec -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" products-mysql mysql -uroot -e \
  "CREATE DATABASE shop CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" \
  products-mysql mysql -uroot --force shop < dump.sql

docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" products-mysql \
  mysql --default-character-set=utf8mb4 -uroot < 03-verify.sql
```

После восстановления снова найдены обе таблицы. В `products1` и `products2` по четыре строки; названия и цены полностью совпали с исходными данными.

Для дополнительной проверки строки обеих таблиц были отсортированы и сравнены до удаления и после восстановления. В обоих случаях получена одинаковая контрольная сумма SHA-256:

```text
1e890d94c6e9529400ad0234d979130a26d552d827627bd2c2936e0181b909bd
```

## Вывод

В ходе работы создана база `shop`, заполнены таблицы `products1` и `products2`, выполнены выборка, проекция, объединение, разность, пересечение, декартово произведение, внутреннее и левое соединения. Создан реальный дамп, исходная база удалена и успешно восстановлена. Контрольная проверка подтвердила сохранность всех восьми строк.
