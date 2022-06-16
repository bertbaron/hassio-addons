ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.15

FROM golang:1.18.3-alpine3.16 as build
LABEL maintainer = "bertusbaron@gmail.com"
ENV LOGSPOUT_VERSION=3.2.14
ENV LOGSPOUT_DOWNLOAD_SHA256=e921ab43b6fe9bb256a588dd118d5a4e060332807344e2d47228312b2f577857
RUN mkdir -p /go/src
WORKDIR /go/src
VOLUME /mnt/routes
EXPOSE 80

RUN apk --no-cache add curl git gcc musl-dev
RUN curl -fSL -o logspout.tar.gz "https://github.com/gliderlabs/logspout/archive/v${LOGSPOUT_VERSION}.tar.gz" \
    && echo "$LOGSPOUT_DOWNLOAD_SHA256 *logspout.tar.gz" | sha256sum -c - \
    && tar -zxvf logspout.tar.gz \
    && rm logspout.tar.gz \
    && mkdir -p /go/src/github.com/gliderlabs/ \
    && mv logspout-${LOGSPOUT_VERSION} /go/src/github.com/gliderlabs/logspout

WORKDIR /go/src/github.com/gliderlabs/logspout
RUN echo 'import ( _ "github.com/bertbaron/logspout-gelf" )' >> /go/src/github.com/gliderlabs/logspout/modules.go
RUN go get -d -v ./...

COPY adapters adapters
RUN echo 'import ( _ "github.com/gliderlabs/logspout/adapters/loki" )' >> /go/src/github.com/gliderlabs/logspout/modules.go
RUN go get -d -v ./...
RUN go build -v -ldflags "-X main.Version=$(cat VERSION)" -o /go/bin/logspout

FROM $BUILD_FROM
COPY --from=build /go/bin/logspout /logspout

COPY rootfs /
CMD ["/start"]