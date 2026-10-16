#!/bin/sh
set -eu

psql --set ON_ERROR_STOP=1 \
  --username "$POSTGRES_USER" \
  --dbname "$POSTGRES_DB" \
  --set app_password="$POSTGRES_APP_PASSWORD" \
  --file /opt/lab/init.sql
