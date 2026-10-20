# Лабораторная работа 3. Node.js Pipeline

## Цель

Настроить непрерывную интеграцию Node.js-приложения: ESLint, тесты Jest в нескольких версиях Node.js и сборку Docker-образа без публикации.

## Структура

- `src/index.js` — функция `add()` и запуск приложения.
- `tests/index.test.js` — три теста Jest.
- `package.json` и `package-lock.json` — зависимости и воспроизводимая установка через `npm ci`.
- `.eslintrc.json` — конфигурация ESLint.
- `Dockerfile` — контейнер приложения на Node.js 18 Alpine.
- [ci-nodejs.yml](../../.github/workflows/ci-nodejs.yml) — workflow GitHub Actions.

## Локальная проверка

```bash
npm ci
npm run lint
npm test
```

Ожидаемый результат: три успешно пройденных теста и отсутствие ошибок ESLint.

Локальная проверка выполнена успешно: ESLint не обнаружил ошибок, все три теста Jest пройдены.

## Docker

```bash
docker build -t my-node-app:test .
docker run --rm my-node-app:test
```

Контейнер выводит `Hello from Node.js app!`. Образ собирается только для проверки и никуда не публикуется.

Локальная сборка и запуск контейнера завершились успешно; ожидаемое сообщение получено.

## CI

Workflow выполняет `npm ci`, линтинг и тесты на Node.js 18, 20 и 22. После успешных проверок отдельная задача собирает Docker-образ. Результаты доступны на странице [Node.js CI](https://github.com/Andrey76546/berendakovMfua/actions/workflows/ci-nodejs.yml).

## Скриншот выполнения

Подтверждение успешного запуска будет добавлено после первой онлайн-проверки.
