# See https://github.com/home-assistant/docker-base
ARG BUILD_FROM=ghcr.io/home-assistant/base:3.22

FROM golang:1.26.3-alpine3.22 AS build
LABEL maintainer="bertusbaron@gmail.com"
ENV LOGSPOUT_HASSIO_VERSION='hassio-8'

WORKDIR /go/src/github.com/bertbaron/

RUN apk add --no-cache git
RUN git clone --depth 1 https://github.com/bertbaron/logspout.git -b ${LOGSPOUT_HASSIO_VERSION}
WORKDIR /go/src/github.com/bertbaron/logspout

# for local development, comment out before commit!
# RUN rm -rf *
# COPY local/logspout/go.* ./
# RUN go mod download
# COPY local/logspout/ .
# end for local development

ENV CGO_ENABLED=0
RUN go build -v -ldflags "-X main.Version=$(cat VERSION)-${LOGSPOUT_HASSIO_VERSION}" -o /go/bin/logspout

FROM $BUILD_FROM
COPY --from=build /go/bin/logspout /logspout

COPY rootfs /
CMD ["/start"]
