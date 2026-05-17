# See https://github.com/home-assistant/docker-base
# Also update build.yaml!
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.22
ARG HOST_PLATFORM=linux/amd64

FROM --platform=$HOST_PLATFORM golang:1.26.3-alpine3.22 AS build
ARG BUILD_ARCH=amd64
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
ENV GOOS=linux

# Map BUILD_ARCH to GOARCH
RUN case "${BUILD_ARCH}" in \
      aarch64) GOARCH=arm64 ;; \
      amd64) GOARCH=amd64 ;; \
      *) echo "Unsupported BUILD_ARCH: ${BUILD_ARCH}" && exit 1 ;; \
    esac && \
    echo "Building for architecture: ${GOARCH} (GOARM=$GOARM)" && \
    echo "export GOARCH=${GOARCH}" > go.env \
    echo "export GOARM=${GOARM}" >> go.env

RUN source go.env && go build -v -ldflags "-X main.Version=$(cat VERSION)-${LOGSPOUT_HASSIO_VERSION}" -o /go/bin/logspout

FROM $BUILD_FROM
COPY --from=build /go/bin/logspout /logspout

COPY rootfs /
CMD ["/start"]
