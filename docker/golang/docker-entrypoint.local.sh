#!/usr/bin/env bash

set -e

if [[ ${FORCE_MIGRATE:-false} == true ]]; then
    printf "\n\033[33m💥 Applying all up database migrations.\033[0m\n\n"

    migrate -path ./migrations -database "mysql://${DB_DSN:1:-1}" up || true
fi

printf "\n"
printf '==============================\n'
printf "\033[34m[ENTRYPOINT] Launching APP ...\033[0m\n"
printf '==============================\n'

exec air -- -port=${APP_PORT} -db-dsn=${DB_DSN} -smtp-username=${MAIL_USERNAME:-""} -smtp-password=${MAIL_PASSWORD:-""} "$@"
