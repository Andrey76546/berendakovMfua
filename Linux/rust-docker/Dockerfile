# ---- Этап 1: Сборка ----
FROM rust:1-slim AS builder

WORKDIR /app

# 1. Копируем манифест
COPY Cargo.toml .

# 2. Создаём фиктивный main.rs, чтобы собрать зависимости отдельным слоем
RUN mkdir src && echo "fn main() {}" > src/main.rs

# 3. Собираем зависимости (кэшируется, если Cargo.toml не менялся)
RUN cargo build --release

# 4. Удаляем фиктивный бинарник, чтобы не остался в образе
RUN rm -f target/release/rust-app target/release/deps/rust_app-*

# 5. Копируем настоящий исходный код
COPY src ./src

# 6. Собираем финальное приложение
RUN cargo build --release

# ---- Этап 2: Минимальный образ для запуска ----
FROM debian:stable-slim

# Непривилегированный пользователь (безопасность)
RUN useradd --create-home appuser

WORKDIR /home/appuser

# Копируем только собранный бинарник из builder
COPY --from=builder /app/target/release/rust-app ./rust-app

# Переключаемся на непривилегированного пользователя
USER appuser

# Если приложение — веб-сервер, раскомментируйте нужный порт
# EXPOSE 8081

# Запуск в JSON-формате — корректная обработка сигналов
CMD ["./rust-app"]