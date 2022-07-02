#!/usr/bin/env bash

set -e

printf "\n"
printf '==============================\n'
printf "\033[34m[ENTRYPOINT] Launching APP ...\033[0m\n"
printf '==============================\n'

exec air -- -port=${APP_PORT} -db-dsn=${DB_DSN} "$@"
