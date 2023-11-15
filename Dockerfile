FROM alpine:latest

RUN apk add --no-cache bash curl upx xz build-base git openssh-client perl

RUN git clone https://github.com/ruanformigoni/coreutils-static.git

WORKDIR coreutils-static

RUN ./build.sh
