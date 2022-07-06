#!/usr/bin/env bash

set -e

shopt -s dotglob
sudo chown -R ${USER_NAME}:${USER_NAME} \
        /home/${USER_NAME} \
        /var/run \
        /var/log
shopt -u dotglob

printf "\n\033[34m--- ENTRYPOINT APP --- \033[0m\n"

if [ -z "$DB_DSN" ]; then
    printf "\n\033[31mA \$DB_DSN environment is required to run this container!\033[0m\n"
    exit 1
fi

if [[ ${FORCE_MIGRATE:-false} == true ]]; then
    printf "\n\033[33m💥 Applying all up database migrations.\033[0m\n\n"

    migrate -path ./migrations -database "mysql://${DB_DSN:1:-1}" up || true
fi

printf "\n"
printf '=================\n'
printf "\033[34mLaunching APP ...\033[0m\n"
printf '=================\n\n'

DB_DSN_WITHOUT_DOUBLE_QUOTE=`sed -e 's/^"//' -e 's/"$//' <<< $DB_DSN`

exec ./main -port=${APP_PORT} -db-dsn=${DB_DSN_WITHOUT_DOUBLE_QUOTE} -smtp-username=${MAIL_USERNAME:-""} -smtp-password=${MAIL_PASSWORD:-""} "$@"
