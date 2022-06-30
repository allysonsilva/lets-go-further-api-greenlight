# Include variables from the .envrc file
-include .envrc
export

# Internal functions
define message_failure
	"\033[1;31m ❌$(1)\033[0m"
endef

define message_success
	"\033[1;32m ✅$(1)\033[0m"
endef

define message_info
	"\033[0;34m❕$(1)\033[0m"
endef

uname_OS := $(shell uname -s)
user_UID := $(shell id -u)
user_GID := $(shell id -g)
current_uid ?= "${user_UID}:${user_GID}"

ifeq ($(uname_OS),Darwin)
	user_UID := 1001
	user_GID := 1001
endif

# ==================================================================================== #
# HELPERS
# ==================================================================================== #

## help: print this help message
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

# Create the new confirm target.
.PHONY: confirm
confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

# ==================================================================================== #
# DEVELOPMENT
# ==================================================================================== #

## run/api: run the cmd/api application
.PHONY: run/api
run/api:
	go run ./cmd/api -db-dsn=${DB_DSN}

## db/migrations/new name=$1: create a new database migration
.PHONY: db/migrations/new
db/migrations/new:
	@echo 'Creating migration files for ${name}...'
	migrate create -seq -ext .sql -dir ./migrations ${name}

## db/migrations/up: apply all up database migrations
.PHONY: db/migrations/up
db/migrations/up: confirm
	@echo 'Running up migrations...'
	migrate -path ./migrations -database "mysql://$(shell echo $(DB_DSN))" up

# ==================================================================================== #
# QUALITY CONTROL
# ==================================================================================== #

## audit: tidy dependencies and format, vet and test all code
# ## The ./… pattern ##
# Most of the go tools support the ./... wildcard pattern,
# like go fmt ./..., go vet ./... and go test ./.... This pattern
# matches the current directory and all sub-directories, excluding the vendor directory.
#
# Generally speaking, this is useful because it means that we’re not formatting,
# vettingm or testing the code in our vendor directory unnecessarily — and our
# make audit rule won’t fail due to any problems that might exist within those vendored packages.
.PHONY: audit
audit:
	@echo 'Formatting code...'
# Use the go fmt ./... command to format all .go files in the project directory, according to the Go standard.
# This will reformat files ‘in place’ and output the names of any changed files.
	go fmt ./...
	@echo 'Vetting code...'
# Use the go vet ./... command to check all .go files in the project directory.
# The go vet tool runs a variety of analyzers which carry out static analysis of your code and
# warn you about things which might be wrong but won’t be picked up by the compiler — such as unreachable code,
# unnecessary assignments, and badly-formed build tags.
	go vet ./...
# Use the third-party staticcheck tool to carry out some additional static analysis checks.
	staticcheck ./...
	@echo 'Running tests...'
# Use the go test -race -vet=off ./... command to run all tests in the project directory.
# By default, go test automatically executes a small subset of the go vet checks before running any tests,
# so to avoid duplication we’ll use the -vet=off flag to turn this off.
# The -race flag enables Go’s race detector, which can help pick up certain classes of
# race conditions while tests are running.
	go test -race -vet=off ./...

## vendor: tidy and vendor dependencies
# - The go mod tidy command will make sure the go.mod and go.sum files list all the necessary dependencies for our project (and no unnecessary ones).
# - The go mod verify command will verify that the dependencies stored in your module cache (located on your machine at $GOPATH/pkg/mod) match the cryptographic hashes in the go.sum file.
# - The go mod vendor command will then copy the necessary source code from your module cache into a new vendor directory in your project root.
.PHONY: vendor
vendor:
	@echo 'Tidying and verifying module dependencies...'
# Use the go mod tidy command to prune any unused dependencies from the go.mod and go.sum files,
# and add any missing dependencies.
	go mod tidy
# Use the go mod verify command to check that the dependencies on your computer
# (located in your module cache located at $GOPATH/pkg/mod) haven’t been changed
# since they were downloaded and that they match the cryptographic hashes in your go.sum file.
# Running this helps ensure that the dependencies being used are the exact ones that you expect.
	go mod verify
	@echo 'Vendoring dependencies...'
	go mod vendor

# ==================================================================================== #
# BUILD
# ==================================================================================== #

# current_time = $(shell date --iso-8601=seconds)
current_time = $(shell date -u +"%Y-%m-%dT%H:%M:%S+%Z")
git_description = $(shell git describe --always --dirty --tags --long)
linker_flags = '-s -X main.buildTime=${current_time} -X main.version=${git_description}'

## build/api: build the cmd/api application
.PHONY: build/api
build/api:
	@echo 'Building cmd/api...'
	go build -v -ldflags=${linker_flags} -o=./bin/main ./cmd/api
# go tool dist list
	GOOS=linux GOARCH=amd64 go build -ldflags=${linker_flags} -o=./bin/linux_amd64/main ./cmd/api

# ==================================================================================== #
# DOCKER
# ==================================================================================== #

.PHONY: docker/config-env
docker/config-env:
	@cd docker && cp -n .env.compose .env || true
	@cd docker && sed -i "/^# PWD/c\PWD=$(shell pwd)" .env
	@cd docker && sed -i "/^# ROOT_PATH/c\ROOT_PATH=$(shell pwd)" .env
	@cd docker && sed -i "/# USER_UID=.*/c\USER_UID=$(user_UID)" .env
	@cd docker && sed -i "/# USER_GID=.*/c\USER_GID=$(user_GID)" .env
	@cd docker && sed -i "/^# CURRENT_UID/c\CURRENT_UID=${current_uid}" .env
	@echo
	@echo $(call message_success, Run \`make docker/config-env\` successfully executed)

.PHONY: docker/build
docker/build:
	@echo
	@echo $(call message_info, Build an image APP... 🏗)
	@echo
	docker-compose \
		-f ./docker/golang/docker-compose.yml \
		--ansi=auto \
		--env-file ./docker/.env \
		build app

.PHONY: docker/up
docker/up:
	@echo
	@echo $(call message_info, Running docker application... 🚀)
	@echo
	@docker-compose -f ./docker/docker-compose.yml up
	@echo
	@docker-compose -f ./docker/mysql/docker-compose.yml --ansi=auto --env-file ./docker/.env up --force-recreate --no-build --no-deps --detach
	@echo
	@sleep 60
	@docker-compose -f ./docker/golang/docker-compose.yml --ansi=auto --env-file ./docker/.env up --force-recreate --no-build --no-deps
