# PostgreSQL

Работа выполнена по [заданию преподавателя](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/PostgresSQL.md). Скрипты `scripts/init.sh` и `scripts/init.sql` создают отдельную роль, базу `app_db`, таблицу `users` и тестовые записи при первой инициализации тома.

## Запуск

```powershell
$env:DC_POSTGRES_PASSWORD = Read-Host 'PostgreSQL administrator password'
$env:DC_POSTGRES_APP_PASSWORD = Read-Host 'PostgreSQL app_user password'
docker compose config
docker compose up -d
```

PostgreSQL доступен только на `127.0.0.1:5432`. Для остановки без удаления данных: `docker compose stop`.

## Результат проверки

- `docker compose config --quiet` выполнена без ошибок.
- PostgreSQL перешёл в состояние `healthy`; версия сервера — 15.19.
- Инициализация завершилась командами `CREATE ROLE`, `CREATE DATABASE`, `CREATE TABLE` и `INSERT 0 2`.
- Под ролью `app_user` подтверждено подключение к `app_db`.
- Из таблицы `users` прочитаны две учебные записи: Иван Иванов и Мария Петрова.
- Контейнер остановлен с кодом 0, том сохранён.

**Статус: выполнено.**

## Скриншоты выполнения

У этой лабораторной нет веб-интерфейса. Автоматический графический захват консоли в доступной среде не выполнялся, а искусственное изображение терминала не создавалось.

Фактическая повторная проверка выполнена командами `docker compose ps` и `psql`: контейнер был `healthy`, подключение прошло как `app_user` к `app_db`, таблица `users` вернула две учебные строки. После обнаружения недочёта init-скрипт исправлен явным `\connect app_db app_user`.
