# Hello Go

Учебное Go-приложение с тестами, multi-stage Docker-сборкой и CI/CD в GitHub Actions.

## Локальная проверка

```shell
go fmt ./...
go vet ./...
go test -v -cover ./...
go run .
```

## Docker

```shell
docker build -t hello-go:local .
docker run --rm hello-go:local
```

## GHCR

При push в `main` workflow публикует образ с тегами `latest` и коротким SHA коммита:

```shell
docker pull ghcr.io/andrey76546/hello-go:latest
docker run --rm ghcr.io/andrey76546/hello-go:latest
```
