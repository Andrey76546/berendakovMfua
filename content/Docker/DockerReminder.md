## Шпаргалка по Docker

### Установка

Windows 10-11
```powershell
winget install Docker.DockerDesktop
```
- **Docker Desktop** должен быть запущен
- Папка проекта должна быть в разрешённых для **Docker Desktop** дисках (`Settings` → `Resources` → `File Sharing`)
- Первый запуск может быть долгим
Alt Linux 11
```shell
apt-get install docker-engine docker-compose
```
MacOS
```shell
brew install --cask docker
```

### Основные команды

#### Состояние

```shell
docker version
```
или кратко
```shell
docker --version
```
Покзать все контейнеры, включая остановленные:
```shell
docker ps -a
```
Показать все имеющиеся Docker-образы
```shell
docker images
```
Быстрая демонстрация работы Docker
```shell
docker run hello-world
```
Получить сводку по диску Docker
```shell
docker system df
```
Получить сводку по всем томам
```shell
docker volume ls
```
Получить список томов с размером
```shell
docker system df -v
```
Артефакты и свободное место:
```shell
docker buildx du
```
Очистить все ненужные тома
```shell
docker volume prune -a
```
и для кэша всех сборок
```shell
docker builder prune
```

#### Образы

Получить список всех образов
```shell
docker images
```
Показать детальную информацию по выбранному образу
```shell
docker image inspect hello-world
```
Найти указанный образ
```shell
docker search nginx
```
Получить информацию по указанному образу
```shell
ocker inspect nginx
```
Получить указанный образ
```shell
docker pull nginx
```
Удалить указанные образ
```shell
docker image rm имя_образа
```
или
```shell
docker rmi имя_образа
```
или удалить образ по его id
```shell
docker rm id_образа
```
Удалить только промежуточные образы (без тегов)
```shell
docker image prune
```
или удалить все образы с подтверждением
```shell
docker image prune -a
```
или
```shell
docker rmi $(docker images -a -q)
```
или
```shell
docker rmi -f $(docker images -q)
```

#### Контейнеры

Получить список запущенных контейнеров
```shell
docker ps
```
Получить список всех контейнеров, не зависимо от их состояния
```shell
docker ps -a
```
Получить список контейнеров, из которых выполнен выход
```shell
docker ps -a -f status=exited
```
Остановить контейнер:
```shell
docker stop my-nginx
```
Остановить все запущенные контейнеры
```shell
docker stop $(docker ps -q)
```
Запустить контейнер:
```shell
docker start my-nginx
```
Проверить состояние сетевых подключений Docker-контейнеров:
```shell
docker network ls
```
Проверка указанного порта

Linux
```shell
netstat -tuln | grep :8082
```
Windows
```powershell
netstat -aon | findstr :8082
```
Зайти в контейнер в интерактивном режиме
```shell
docker exec -it my-apache bash
```
Удалить все остановленные или не запущенные (Exited, Created) контейнеры
```shell
docker container prune
```
`Prune` - Удаляйте ненужные контейнеры чтобы не засорять ваш Docker!

или
```shell
docker rm $(docker ps -aq)
```
Удаление остановленных контейнеров
```shell
docker rm $(docker ps -a -f status=exited -q)
```

#### Docker Compose

Остановить контейнер:
```shell
docker compose down
```

Остановить контейнер и удалить данные:
```shell
docker compose down -v
```

### DOCKER HUB

docker pull nginx
docker pull postgres
docker pull redis
# На самом деле это:
docker pull docker.io/library/nginx:latest
docker search nginx
docker inspect nginx
docker pull nginx:alpine

### Ресурсы

- [](/content/Docker/Docs/Codespace.md)
- [](/content/Docker/Docs/Dockerfile&DockerCompose.md)
- [](/content/Docker/Docs/DockerfileInfo.md)
- [](/content/Docker/Docs/DockerImageLifecycle.md)
- [](/content/Docker/Docs/DockerHub.md)
- [](/content/Docker/Docs/dockerStats.md)
- [](/content/Docker/Docs/Network.md)
- [](/content/Docker/Docs/Portainer_info.md)
- [](/content/Docker/Docs/Productiom.md)
- [](/content/Docker/Docs/Prune.md)
- [](/content/Docker/Docs/stopDown.md)
- [](/content/Docker/Docs/ThatIsDocker.md)
- [](/content/Docker/Docs/)

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
