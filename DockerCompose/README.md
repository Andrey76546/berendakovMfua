# Лабораторные работы Docker Compose

В каталоге собраны девять основных самостоятельных работ из [раздела Docker Compose курса](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/README.md). Необязательные проекты `videoeditor` и `arcada` не выполнялись. Все опубликованные порты привязаны только к `127.0.0.1`, а данные сохраняются в именованных томах или локальных каталогах, исключённых из Git.

## Результаты

| № | Работа | Назначение | Технологии | Фактическая проверка | Статус | Скриншоты |
|---:|---|---|---|---|---|---|
| 1 | [MySQL + phpMyAdmin](mysql-phpmyadmin/) | База данных и веб-интерфейс администрирования | MySQL 8.0, phpMyAdmin | MySQL `healthy`, тестовая запись прочитана, HTTP 200 | Выполнено | Ожидаются |
| 2 | [PostgreSQL](postgresql/) | Инициализация БД, роли и тестовых данных | PostgreSQL 15, SQL, shell | PostgreSQL `healthy`, роль и две записи проверены | Выполнено | Ожидаются |
| 3 | [PostgreSQL + pgAdmin](postgresql-pgadmin/) | База данных с веб-интерфейсом | PostgreSQL 17, pgAdmin 4 | БД `healthy`, тестовая запись прочитана, HTTP 200 | Выполнено | Ожидаются |
| 4 | [WordPress](wordpress/) | Локальный сайт с отдельной БД | WordPress, WP-CLI, MySQL 8.0 | Установка завершена, БД проверена, сайт и вход — HTTP 200 | Выполнено | Ожидаются |
| 5 | [Joomla](joomla/) | Локальная CMS с MariaDB | Joomla, MariaDB 11.5.2 | Автоустановка завершена, 76 таблиц, обе страницы — HTTP 200 | Выполнено | Ожидаются |
| 6 | [drawDB](drawdb/) | Визуальный редактор схем БД | drawDB, nginx | Страница доступна на localhost, HTTP 200 | Выполнено | Ожидаются |
| 7 | [LibreDB Studio](libredb-studio/) | Веб-интерфейс для работы с БД | LibreDB Studio, Next.js | Контейнер `healthy`, переход на `/login`, страница входа — HTTP 200 | Выполнено | Ожидаются |
| 8 | [CloudBeaver](cloudbeaver/) | Универсальный веб-клиент БД | CloudBeaver Community | HTTP 200, `/status`: `health=ok`, версия 26.2.2 | Выполнено | Ожидаются |
| 9 | [Homehub](homehub/) | Локальная семейная панель | Homehub, Gunicorn | Контейнер `healthy`, `/healthz` и главная — HTTP 200 | Выполнено | Ожидаются |

## Общий порядок запуска

Из папки выбранной лабораторной задайте требуемые переменные окружения, указанные в её README, затем выполните:

```powershell
docker compose config
docker compose up -d
docker compose ps
```

После проверки остановите только текущую работу, сохранив тома:

```powershell
docker compose stop
```

Пароли и ключи в репозитории отсутствуют. Файлы `.env`, базы, загрузки и рабочие данные исключены правилами `.gitignore`.

## План скриншотов

Запускайте только один проект за раз командой `docker compose up -d`, а после снимков выполняйте `docker compose stop`. На каждом терминальном снимке полезно показать `docker compose ps`; пароли, ключи и содержимое `.env` в кадр попадать не должны.

| Проект | Адрес | Что сфотографировать |
|---|---|---|
| MySQL + phpMyAdmin | <http://localhost:8083> | Контейнеры, вход phpMyAdmin, таблицу `compose_check` со строкой `mysql-ok` |
| PostgreSQL | Веб-интерфейса нет | Статус `healthy`, `current_user/current_database`, две строки таблицы `users` в `psql` |
| PostgreSQL + pgAdmin | <http://localhost:5050> | Контейнеры, страницу pgAdmin, Query Tool со строкой `pgadmin-ok` |
| WordPress | <http://localhost:8081> | Контейнеры, главную сайта и форму входа или панель администратора |
| Joomla | <http://localhost:8082> | Контейнеры, главную сайта и `/administrator/` |
| drawDB | <http://localhost:5173> | Контейнер и редактор с небольшой схемой из двух связанных таблиц |
| LibreDB Studio | <http://localhost:3000> | Статус `healthy`, страницу входа и форму тестового подключения без учётных данных |
| CloudBeaver | <http://localhost:8978> | Контейнер, мастер первоначальной настройки или интерфейс, ответ `/status` |
| Homehub | <http://localhost:5000> | Статус `healthy`, главную панель и один раздел с обезличенными тестовыми данными |
