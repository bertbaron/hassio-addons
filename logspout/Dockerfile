# Minimal runtime image for the Home Assistant app
ARG BUILD_FROM=alpine:3.22

FROM golang:1.26.3-alpine3.22 AS build
LABEL maintainer="bertusbaron@gmail.com"
RUN apk add --no-cache git
WORKDIR /src/logspout

COPY local/logspout/go.mod local/logspout/go.sum ./
RUN go mod download

COPY local/logspout/ ./

ENV CGO_ENABLED=0
RUN go build -v -ldflags "-X main.Version=$(cat VERSION)" -o /out/logspout ./cmd/launcher

FROM $BUILD_FROM
RUN apk add --no-cache ca-certificates
COPY --from=build /out/logspout /logspout

CMD ["/logspout"]
