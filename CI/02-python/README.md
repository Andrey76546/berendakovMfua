# Лабораторная работа 2. Python Pipeline

## Цель

Настроить непрерывную интеграцию Python-приложения: проверку стиля, автоматические тесты в нескольких версиях Python и сборку Docker-образа без публикации.

## Структура

- `myapp/app.py` — функция `add()` и точка запуска приложения.
- `tests/test_app.py` — три теста `pytest`.
- `requirements.txt` — зависимости для тестирования и линтинга.
- `setup.py` — установка пакета в режиме разработки.
- `Dockerfile` — контейнер приложения на Python 3.11.
- [ci-python.yml](../../.github/workflows/ci-python.yml) — workflow GitHub Actions.

## Локальная проверка

```bash
python -m pip install -r requirements.txt
python -m pip install -e .
flake8 myapp tests setup.py --count --max-line-length=127 --statistics
pytest tests/
```

Ожидаемый результат: три успешно пройденных теста и отсутствие ошибок `flake8`.

Локальная проверка выполнена успешно: `flake8` завершился с кодом `0`, все три теста `pytest` пройдены на Python 3.12.

## Docker

```bash
docker build -t my-python-app:test .
docker run --rm my-python-app:test
```

Контейнер выводит `Hello from my Python app!`. Образ собирается только для проверки и никуда не публикуется.

Локальная сборка и запуск контейнера завершились успешно; ожидаемое сообщение получено.

## CI

Workflow проверяет проект на Python 3.9, 3.10, 3.11 и 3.12. После успешного линтинга и тестов отдельная задача собирает Docker-образ. Результаты доступны на странице [Python CI](https://github.com/Andrey76546/berendakovMfua/actions/workflows/ci-python.yml).

## Скриншот выполнения

Подтверждение успешного запуска будет добавлено после первой онлайн-проверки.
