# Лабораторные работы Docker Compose

В каталоге собраны девять основных самостоятельных работ из [раздела Docker Compose курса](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/README.md). Необязательные проекты `videoeditor` и `arcada` не выполнялись. Все опубликованные порты привязаны только к `127.0.0.1`, а данные сохраняются в именованных томах или локальных каталогах, исключённых из Git.

## Результаты

| № | Работа | Назначение | Технологии | Фактическая проверка | Статус | Скриншоты |
|---:|---|---|---|---|---|---|
| 1 | [MySQL + phpMyAdmin](mysql-phpmyadmin/) | База данных и веб-интерфейс администрирования | MySQL 8.0, phpMyAdmin | MySQL `healthy`, тестовая запись прочитана, HTTP 200 | Выполнено | [Есть](mysql-phpmyadmin/screenshots/phpmyadmin-login.png) |
| 2 | [PostgreSQL](postgresql/) | Инициализация БД, роли и тестовых данных | PostgreSQL 15, SQL, shell | PostgreSQL `healthy`, `app_user@app_db`, две записи проверены | Выполнено | Нет веб-интерфейса |
| 3 | [PostgreSQL + pgAdmin](postgresql-pgadmin/) | База данных с веб-интерфейсом | PostgreSQL 17, pgAdmin 4 | БД `healthy`, тестовая запись прочитана, HTTP 200 | Выполнено | [Есть](postgresql-pgadmin/screenshots/pgadmin-login.png) |
| 4 | [WordPress](wordpress/) | Локальный сайт с отдельной БД | WordPress, WP-CLI, MySQL 8.0 | Установка завершена, БД проверена, сайт — HTTP 200 | Выполнено | [Есть](wordpress/screenshots/wordpress-home.png) |
| 5 | [Joomla](joomla/) | Локальная CMS с MariaDB | Joomla, MariaDB 11.5.2 | Автоустановка завершена, 76 таблиц, главная — HTTP 200 | Выполнено | [Есть](joomla/screenshots/joomla-home.png) |
| 6 | [drawDB](drawdb/) | Визуальный редактор схем БД | drawDB, nginx | Страница доступна на localhost, HTTP 200 | Выполнено | [Есть](drawdb/screenshots/drawdb-editor.png) |
| 7 | [LibreDB Studio](libredb-studio/) | Веб-интерфейс для работы с БД | LibreDB Studio, Next.js | Контейнер `healthy`, страница входа — HTTP 200 | Выполнено | [Есть](libredb-studio/screenshots/libredb-login.png) |
| 8 | [CloudBeaver](cloudbeaver/) | Универсальный веб-клиент БД | CloudBeaver Community | `/status`: `health=ok`, версия 26.2.2 | Выполнено | [Интерфейс](cloudbeaver/screenshots/cloudbeaver-setup.png), [status](cloudbeaver/screenshots/cloudbeaver-status.png) |
| 9 | [Homehub](homehub/) | Локальная семейная панель | Homehub, Gunicorn | Контейнер `healthy`, `/healthz` и главная — HTTP 200 | Выполнено | [Есть](homehub/screenshots/homehub-dashboard.png) |

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

## Скриншоты выполнения

Опубликовано девять настоящих снимков восьми веб-приложений. Они получены изолированным headless-браузером только с адресов `localhost` и проверены визуально перед публикацией. Поля входа оставлены пустыми; пароли, cookies, токены, локальные пути и личные данные отсутствуют.

Чистая лабораторная PostgreSQL не имеет веб-интерфейса. Для неё вместо искусственного изображения сохранено честное описание фактической проверки через `docker compose ps` и `psql` в README проекта.
