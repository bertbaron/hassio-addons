# Runtime image for the Home Assistant app.
# Debian is used because the journal log source needs libsystemd.
ARG LOGSPOUT_REPOSITORY=https://github.com/bertbaron/logspout.git
ARG LOGSPOUT_VERSION=
ARG LOGSPOUT_REF=
ARG LOGSPOUT_SOURCE=local
ARG BUILD_FROM=debian:trixie-slim

FROM golang:1.26.4-trixie AS build
LABEL maintainer="bertusbaron@gmail.com"
ARG LOGSPOUT_REPOSITORY
ARG LOGSPOUT_VERSION
ARG LOGSPOUT_REF
ARG LOGSPOUT_SOURCE
RUN apt-get update \
	&& apt-get install -y --no-install-recommends git libsystemd-dev \
	&& rm -rf /var/lib/apt/lists/*
WORKDIR /src

COPY . /context

RUN set -eux; \
	case "$LOGSPOUT_SOURCE" in \
		local) \
			test -f /context/local/logspout/go.mod; \
			cp -a /context/local/logspout /src/logspout; \
			;; \
		git) \
			if [ -n "$LOGSPOUT_VERSION" ]; then \
				git clone --depth 1 --branch "$LOGSPOUT_VERSION" "$LOGSPOUT_REPOSITORY" /src/logspout; \
				if [ -n "$LOGSPOUT_REF" ]; then \
					resolved_ref="$(git -C /src/logspout rev-parse HEAD)"; \
					if [ "$resolved_ref" != "$LOGSPOUT_REF" ]; then \
						echo "Resolved $LOGSPOUT_VERSION to $resolved_ref, expected $LOGSPOUT_REF" >&2; \
						exit 1; \
					fi; \
				fi; \
			elif [ -n "$LOGSPOUT_REF" ]; then \
				git clone --depth 1 --branch "$LOGSPOUT_REF" "$LOGSPOUT_REPOSITORY" /src/logspout || \
				(git clone --depth 1 "$LOGSPOUT_REPOSITORY" /src/logspout && cd /src/logspout && git fetch --depth 1 origin "$LOGSPOUT_REF" && git checkout FETCH_HEAD); \
			else \
				git clone --depth 1 "$LOGSPOUT_REPOSITORY" /src/logspout; \
			fi; \
			;; \
		*) \
			echo "Unsupported LOGSPOUT_SOURCE: $LOGSPOUT_SOURCE" >&2; \
			exit 1; \
			;; \
	esac

WORKDIR /src/logspout

RUN go mod download

# cgo is needed for the journal log source (libsystemd is loaded at runtime with dlopen)
ENV CGO_ENABLED=1
RUN go build -v -ldflags "-X main.Version=$(cat VERSION)" -o /out/logspout ./cmd/launcher

FROM $BUILD_FROM
RUN apt-get update \
	&& apt-get install -y --no-install-recommends ca-certificates libsystemd0 \
	&& rm -rf /var/lib/apt/lists/*
COPY --from=build /out/logspout /logspout

CMD ["/logspout"]
