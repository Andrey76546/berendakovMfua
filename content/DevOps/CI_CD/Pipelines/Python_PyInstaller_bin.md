## CI/CD на Python CLI с публикацией бинарников в GitHub Releases

**Сборка Python CLI в один исполняемый файл через PyInstaller**

> **Лабораторная работа выполняется в VS Code!**

**PyInstaller** — это инструмент, который превращает Python-скрипт в самодостаточный исполняемый файл: внутрь упаковывается интерпретатор Python, все зависимости и ваш код. Пользователь скачивает один файл — и запускает, без установки Python.

**GitHub Releases** — раздел репозитория, где публикуются версии проекта: теги, описания и файлы для скачивания.

**Цель** — научиться автоматически собирать бинарники Python CLI под Linux, macOS и Windows и публиковать их в GitHub Releases при push тега v*.

Что узнаете/вспомните:
- **python** — виртуальные окружения (venv), pip, запуск модулей (python -m)
- Встроенные тесты — pytest или unittest
- **PyInstaller** — --onefile, .spec-файл, встраивание версии
- **Cross-compilation** в Python — почему её нет (в отличие от Go)
- Матричные сборки в GitHub Actions — 3 ОС параллельно
- **softprops/action-gh-release** — публикация артефактов
- Семантическое версионирование — теги v1.0.0

Ключевое отличие от **Go/Rust**:

- **Go/Rust** — один runner собирает под все платформы (cross-compilation)
- **Python** — для каждой ОС нужен свой runner, потому что PyInstaller встраивает платформо-зависимый интерпретатор

### 1. Создайте на вашем компьютере, в корневом каталоге текущего пользователя такую структуру:

```text
hello-python/
├── .github/workflows/ci.yml
├── hello/
│   ├── __init__.py
│   └── greeting.py
├── tests/
│   └── test_greeting.py
├── .gitignore
├── main.py
├── pyproject.toml
└── requirements.txt
```
Для перехода в корень текущего пользователя:
```shell
cd ~
```
Создать структуру проекта одной bash-командой (Git Bash / Linux / WSL / macOS):
```shell
mkdir -p hello-python/{.github/workflows,hello,tests} && \
cd hello-python && \

cat > pyproject.toml << 'EOF'
[project]
name = "hello-python"
version = "0.1.0"
description = "Demo Python CLI with PyInstaller and CI/CD"
requires-python = ">=3.10"

[project.scripts]
hello = "main:main"

[build-system]
requires = ["setuptools>=68"]
build-backend = "setuptools.build_meta"

[tool.pytest.ini_options]
testpaths = ["tests"]
EOF

cat > requirements.txt << 'EOF'
pytest==8.3.3
pyinstaller==6.11.0
EOF

cat > hello/__init__.py << 'EOF'
__version__ = "0.1.0"
EOF

cat > hello/greeting.py << 'EOF'
def greet(name: str) -> str:
    return f"Hello, {name}!"


def sum_range(from_: int, to: int) -> int:
    return sum(range(from_, to + 1))
EOF

cat > tests/test_greeting.py << 'EOF'
from hello.greeting import greet, sum_range


def test_greet():
    assert greet("Python") == "Hello, Python!"
    assert greet("CI") == "Hello, CI!"


def test_sum_range():
    assert sum_range(1, 10) == 55
    assert sum_range(1, 100) == 5050
EOF

cat > main.py << 'EOF'
import sys
import platform

from hello import __version__
from hello.greeting import greet, sum_range


def main() -> int:
    print(f"hello-python version {__version__}")
    print("Hello from Python! 🐍📦")
    print(f"OS: {platform.system().lower()}")
    print(f"Arch: {platform.machine()}")
    print(greet("GitHub"))
    print(f"Sum 1..10 = {sum_range(1, 10)}")

    if len(sys.argv) > 1:
        print("Аргументы:")
        for i, arg in enumerate(sys.argv[1:], start=1):
            print(f"  {i}: {arg}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
EOF

cat > .github/workflows/ci.yml << 'EOF'
name: Python CI/CD

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]
  pull_request:

jobs:
  # ===== Job 1: CI — линтер и тесты =====
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v7

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'
          cache: pip

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt

      - name: Lint with ruff
        run: |
          pip install ruff==0.7.1
          ruff check .
          ruff format --check .

      - name: Run tests
        run: pytest -v

  # ===== Job 2: CD — публикация бинарников по тегу =====
  release:
    needs: test
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: ${{ matrix.os }}

    permissions:
      contents: write

    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            artifact: hello-python-linux-x64
          - os: macos-14
            artifact: hello-python-macos-arm64
          - os: windows-latest
            artifact: hello-python-windows-x64.exe

    steps:
      - uses: actions/checkout@v7

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'
          cache: pip

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt

      - name: Build with PyInstaller
        run: pyinstaller --onefile --name hello-python main.py

      - name: Rename binary (Unix)
        if: runner.os != 'Windows'
        run: mv dist/hello-python dist/${{ matrix.artifact }}

      - name: Rename binary (Windows)
        if: runner.os == 'Windows'
        run: mv dist/hello-python.exe dist/${{ matrix.artifact }}

      - name: Upload to Release
        uses: softprops/action-gh-release@v2
        with:
          files: dist/${{ matrix.artifact }}
          generate_release_notes: true
EOF

cat > .gitignore << 'EOF'
__pycache__/
*.pyc
.venv/
venv/
.env
build/
dist/
*.spec
.pytest_cache/
.ruff_cache/
.idea/
.vscode/
*.egg-info/
EOF

echo "✅ Структура создана:"
find . -type f | sort
```

### 2. Тесты в Docker (Python на хосте не нужен)

Git Bash / Linux / WSL / macOS:
```shell
cd ~/hello-python
mkdir -p ~/.pip-docker-cache
docker run --rm \
  -u "$(id -u):$(id -g)" \
  -e HOME=/tmp \
  -v "$(pwd)":/app \
  -v ~/.pip-docker-cache:/tmp/.cache/pip \
  -w /app \
  python:3.12-slim \
  sh -c "pip install --cache-dir=/tmp/.cache/pip -r requirements.txt && pytest -v"
```
PowerShell (Windows):
```powershell
cd ~/hello-python
docker run --rm `
  -v "${PWD}:/app" `
  -w /app `
  python:3.12-slim `
  sh -c "pip install -r requirements.txt && pytest -v"
```
Ожидаемый вывод:
```shell
tests/test_greeting.py::test_greet PASSED
tests/test_greeting.py::test_sum_range PASSED
========================= 2 passed in 0.12s =========================
```

### 3. Локальная сборка бинарника через PyInstaller в Docker

Git Bash / Linux / WSL / macOS:
```shell
cd ~/hello-python
docker run --rm \
  -u "$(id -u):$(id -g)" \
  -e HOME=/tmp \
  -v "$(pwd)":/app \
  -v ~/.pip-docker-cache:/tmp/.cache/pip \
  -w /app \
  python:3.12-slim \
  sh -c "pip install --cache-dir=/tmp/.cache/pip -r requirements.txt && pyinstaller --onefile --name hello-python main.py"
```
PowerShell (Windows):
```powershell
cd ~/hello-python
docker run --rm `
  -v "${PWD}:/app" `
  -w /app `
  python:3.12-slim `
  sh -c "pip install -r requirements.txt && pyinstaller --onefile --name hello-python main.py"
```
После сборки в папке dist/ появится файл hello-python (на Linux). Запустить его можно в том же Docker-контейнере:
```shell
docker run --rm \
  -v "$(pwd)/dist":/dist \
  debian:stable-slim \
  /dist/hello-python
```
Ожидаемый вывод:
```shell
hello-python version 0.1.0
Hello from Python! 🐍📦
OS: linux
Arch: x86_64
Hello, GitHub!
Sum 1..10 = 55
```
Важно: бинарник, собранный в Linux-контейнере, не запустится на Windows или macOS. PyInstaller не умеет cross-compilation — под каждую ОС нужна своя сборка. Именно поэтому в CI мы используем матрицу с тремя runner'ами


### 4. Создание пустого репозитория на GitHub

Создайте пустой репозиторий `hello-python` на **GitHub**.

⚠️ Не добавляйте сразу `README.md`, `.gitignore` и лицензию — иначе push будет отклонён!

### 5. Запушить проект

На всякий случай вернёмся в каталок проекта
```shell
cd ~/hello-python
```
Git Bash / Linux / WSL / macOS:
```shell
git init
git add .
git commit -m "Initial commit: Python CLI with PyInstaller and CI/CD to Releases"
git branch -M main
read -p "Введите ваш GitHub username: " GITHUB_USER
git remote add origin "https://github.com/${GITHUB_USER}/hello-python.git"
git remote -v
git push -u origin main
```
PowerShell (Windows):
```shell
git init
git add .
git commit -m "Initial commit: Python CLI with PyInstaller and CI/CD to Releases"
git branch -M main
$GITHUB_USER = Read-Host "Введите ваш GitHub username"
git remote add origin "https://github.com/$GITHUB_USER/hello-python.git"
git remote -v
git push -u origin main
```

### 6. Первый запуск CI (без релиза)

После `push` в `main` откройте вкладку **Actions** в **GitHub**.

Что произойдёт:
- **Job test** запустится и пройдёт все проверки: `ruff check`, `ruff format --check`, `pytest`
- **Job release** будет пропущен — потому что `push` был в ветку, а не тег
Это нормальное поведение. Релиз создаётся только при `push` тега `v*`.

### 7. Создание релиза

Когда код в main стабилен — создайте тег:
```shell
git tag v1.0.0
git push origin v1.0.0
```
Что произойдёт:
- **test** — снова прогонит тесты
- **release** — запустится, соберёт бинарники параллельно на 3 ОС
- Создастся **GitHub Release v1.0.0** с прикреплёнными файлами
Проверка:
`https://github.com/<ВАШ-USERNAME>/hello-python/releases`

Там должен быть релиз **v1.0.0** с 3 файлами:

* hello-python-linux-x64
* hello-python-macos-arm64
* hello-python-windows-x64.exe


### 8. Скачивание и запуск бинарника

Linux:
```shell
wget https://github.com/<ВАШ-USERNAME>/hello-python/releases/download/v1.0.0/hello-python-linux-x64
chmod +x hello-python-linux-x64
./hello-python-linux-x64
```
macOS (Apple Silicon):
```shell
curl -L -o hello-python-macos-arm64 \
  https://github.com/<ВАШ-USERNAME>/hello-python/releases/download/v1.0.0/hello-python-macos-arm64
chmod +x hello-python-macos-arm64
./hello-python-macos-arm64
```
Windows (PowerShell):
```powershell
Invoke-WebRequest `
  -Uri "https://github.com/<ВАШ-USERNAME>/hello-python/releases/download/v1.0.0/hello-python-windows-x64.exe" `
  -OutFile "hello-python.exe"

.\hello-python.exe
```
Ожидаемый вывод:
```shell
hello-python version 0.1.0
Hello from Python! 🐍📦
OS: linux
Arch: x86_64
Hello, GitHub!
Sum 1..10 = 55
```
Примечание: на **macOS** при первом запуске может появиться предупреждение безопасности. Обходится: `Системные настройки` → `Приватность` и `безопасность` → `Всё равно открыть`.

### 9. Создание нового релиза (опционально)

Для следующего релиза — обновите версию в pyproject.toml и hello/__init__.py, затем:
```shell
git tag v1.1.0
git push origin v1.1.0
```
GitHub создаст новый Release v1.1.0, старый v1.0.0 останется доступным.


Что вы освоили:
- Python — pyproject.toml, venv, pip, python -m
- pytest — тесты и их структура
- ruff — быстрый линтер и форматтер для Python
- PyInstaller — --onefile, упаковка интерпретатора и зависимостей
- Матричные сборки — 3 ОС параллельно, потому что Python не cross-compile
- GitHub Actions — Python toolchain, кэш pip, pytest, pyinstaller
- GitHub Releases — публикация бинарников через softprops/action-gh-release
- Семантическое версионирование — теги v1.0.0, v1.1.0
- Разницу между CI и CI/CD

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!

