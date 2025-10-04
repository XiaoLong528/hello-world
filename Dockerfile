# Multi-stage Dockerfile
# Stage 1: build
FROM fedora:latest AS builder
# Install only the packages we need for building to speed up the build and
# improve layer caching. Avoid `dnf -y update` which invalidates cache.
RUN dnf -y install gcc make libcurl-devel zlib-devel && dnf clean all

WORKDIR /src
COPY . /src
RUN mkdir -p /src/bin && \
    gcc -O2 -Wall src/http_fetch.c -o /src/bin/http_fetch -lcurl -lz

# Stage 2: runtime
FROM fedora:latest
RUN dnf -y install ca-certificates && dnf clean all
COPY --from=builder /src/bin/http_fetch /usr/local/bin/http_fetch
WORKDIR /data
ENTRYPOINT ["/usr/local/bin/http_fetch"]

# Note: host-level docker cleanup commands do not belong in an image and have
# been removed.
