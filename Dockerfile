# If you change this value, please change it in the following files as well:
# /Dockerfile
# /tools/Dockerfile
# /.github/workflows/main.yml
FROM golang:1.23.6-alpine as builder

# Install build dependencies such as git and glide.
RUN apk add --no-cache git gcc musl-dev

RUN apk add --no-cache --update alpine-sdk \
    git \
    make \
    bash \
    gcc

ENV GO111MODULE on
COPY . /go/src/github.com/lightninglabs/lndmon/
RUN cd /go/src/github.com/lightninglabs/lndmon/cmd/lndmon && go build

# Start a new image
FROM alpine:3.21@sha256:56fa17d2a7e7f168a043a2712e63aed1f8543aeafdcee47c58dcffe38ed51099 as final

# renovate: datasource=repology depName=alpine_3_21/bash versioning=loose
ARG BASH_VERSION="5.2.37-r0"

# renovate: datasource=repology depName=alpine_3_21/busybox versioning=loose
ARG BUSYBOX_VERSION="1.37.0-r12"

# renovate: datasource=repology depName=alpine_3_21/iputils versioning=loose
ARG IPUTILS_VERSION="20240905-r0"

COPY --from=builder /go/src/github.com/lightninglabs/lndmon/cmd/lndmon/lndmon /bin/

# Add bash, for quality of life and SSL-related reasons.
RUN apk --no-cache add \
    bash=${BASH_VERSION} \
    busybox=${BUSYBOX_VERSION} \
    iputils=${IPUTILS_VERSION}

ENTRYPOINT ["/bin/lndmon"]
