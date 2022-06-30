ARG LOCAL_DOCKER_FOLDER=./docker

#####
## BUILD STAGE
#####

FROM golang:1.18-alpine3.16 AS builder
# FROM golang:1.18-buster AS builder

RUN set -xe; \
    apk update; \
    apk add --update --no-cache \
        git \
        make; \
    rm -rf /tmp/* /var/cache/apk/*

# Create and change to the app directory.
WORKDIR /app

# Retrieve application dependencies.
# This allows the container build to reuse cached dependencies.
# Expecting to copy go.mod and if present go.sum.
COPY go.* ./
RUN go mod download

# Copy local code to the container image.
COPY . ./

# Build the binary.
RUN make build/api

#####
## RUN STAGE
#####

FROM alpine:3.16
# FROM debian:buster-slim

ARG LOCAL_DOCKER_FOLDER

# Default directory for application deployment
# Location of the folder in the container, path of the folder inside the container
ARG REMOTE_SRC=/var/www/app
ENV REMOTE_SRC $REMOTE_SRC

# Image user
ARG USER_NAME=app
ENV USER_NAME $USER_NAME

ARG USER_UID=1000
ARG USER_GID=1000

# Path docker GO folder
ARG LOCAL_DOCKER_GOLANG_PATH=$LOCAL_DOCKER_FOLDER/golang
ENV LOCAL_DOCKER_GOLANG_PATH $LOCAL_DOCKER_GOLANG_PATH

RUN set -xe; \
    \
    echo "---> Installing Packages Dependencies"; \
    \
    apk update; \
    \
    apk add --update --no-cache \
        fd \
        exa \
        git \
        sudo \
        curl \
        wget \
        make \
        bash \
        tini; \
    \
    rm -rf /tmp/* /var/cache/apk/*

RUN set -xe \
    && echo "---> Adding USER to IMAGE" \
    && addgroup --gid ${USER_GID:-1000} $USER_NAME \
    && adduser --gecos "" --disabled-password --uid ${USER_UID:-1000} --ingroup $USER_NAME --shell /bin/bash $USER_NAME \
    && echo "$USER_NAME ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers \
    # Replace it with /bin/bash:
    && sed -i "/root/s/bin\/ash/bin\/bash/g" /etc/passwd

RUN if [ ! -d "$REMOTE_SRC" ]; then \
        mkdir -p $REMOTE_SRC \
        && chown -R $USER_NAME:$USER_NAME $REMOTE_SRC \
    ;fi

RUN set -xe \
    && echo "---> Changing Permissions" \
    && chown -R $USER_NAME:$USER_NAME \
        /var/run \
        /home/${USER_NAME} \
        /var/log

# ENTRYPOINT
COPY $LOCAL_DOCKER_GOLANG_PATH/docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

#####
## APPLICATION
#####

COPY --from=migrate/migrate:4 /usr/local/bin/migrate /usr/local/bin/migrate
RUN ln -s /usr/local/bin/migrate /migrate

# Application directory
WORKDIR $REMOTE_SRC

# # Define the running USER
USER $USER_NAME

# Remove folder docker
RUN     if [ -d ${LOCAL_DOCKER_FOLDER} ]; then \
            rm -rf ${LOCAL_DOCKER_FOLDER} \
        ;fi

# Copy our application
COPY --from=builder /app/bin/main .
# COPY app.env .
COPY migrations ./migrations

RUN sudo chown -R $USER_NAME:$USER_NAME $REMOTE_SRC

ENTRYPOINT ["/entrypoint.sh"]

# CMD ["--help"]

EXPOSE 4000 8000 8080

# vim:set ft=dockerfile:
