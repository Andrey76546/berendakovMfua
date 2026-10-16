# PostgreSQL + pgAdmin

Работа выполнена по [заданию преподавателя](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/PostgreSQL_pgAdmin.md). PostgreSQL 17 и pgAdmin 4 работают в отдельной сети, а их данные хранятся в именованных томах.

## Запуск

```powershell
$env:DC_PGADMIN_DB_PASSWORD = Read-Host 'PostgreSQL password'
$env:DC_PGADMIN_PASSWORD = Read-Host 'pgAdmin password'
docker compose config
docker compose up -d
```

pgAdmin: <http://localhost:5050>. Учебная учётная запись задаётся в `compose.yaml`, пароль передаётся только через переменную окружения. Остановка: `docker compose stop`.

## Результат проверки

- `docker compose config --quiet` выполнена без ошибок.
- PostgreSQL перешёл в состояние `healthy`.
- Создана таблица `compose_check`, записано и прочитано значение `pgadmin-ok`.
- pgAdmin успешно инициализирован и вернул HTTP 200 на странице входа.
- Недопустимый для актуальной версии pgAdmin адрес с зарезервированным доменом заменён на нейтральный `admin@example.com`.
- Оба контейнера остановлены с кодом 0, тома сохранены.

**Статус: выполнено.**

## Скриншоты выполнения

- [ ] `docker compose ps` с PostgreSQL `healthy` и pgAdmin `Up`.
- [ ] Страница входа pgAdmin на `localhost:5050`.
- [ ] Query Tool с результатом строки `pgadmin-ok`.
