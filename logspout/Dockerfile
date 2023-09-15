ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.18

FROM golang:1.21.0 AS build
LABEL maintainer = "bertusbaron@gmail.com"
ENV LOGSPOUT_HASSIO_VERSION='hassio-3'

WORKDIR /go/src/github.com/bertbaron/

RUN git clone --depth 1 https://github.com/bertbaron/logspout.git -b ${LOGSPOUT_HASSIO_VERSION}
WORKDIR /go/src/github.com/bertbaron/logspout

# for local development, comment out before commit!
# RUN rm -rf *
# COPY local/logspout/go.* ./
# RUN go mod download
# COPY local/logspout/ .
# end for local development

RUN CGO_ENABLED=0 go build -v -ldflags "-X main.Version=$(cat VERSION)-${LOGSPOUT_HASSIO_VERSION}" -o /go/bin/logspout

FROM $BUILD_FROM
COPY --from=build /go/bin/logspout /logspout

COPY rootfs /
CMD ["/start"]