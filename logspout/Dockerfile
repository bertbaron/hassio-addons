# See https://github.com/home-assistant/docker-base
ARG BUILD_FROM=ghcr.io/home-assistant/base:3.22

FROM golang:1.26.3-alpine3.22 AS build
LABEL maintainer="bertusbaron@gmail.com"
ENV LOGSPOUT_HASSIO_VERSION='hassio-7'
ARG LOGSPOUT_HASSIO_REF=036f18213f99a0745ddc2106fe945f3be6ab8c7c

WORKDIR /go/src/github.com/bertbaron/

RUN apk add --no-cache git
RUN git clone https://github.com/bertbaron/logspout.git && \
    cd logspout && \
    git checkout ${LOGSPOUT_HASSIO_REF}
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
