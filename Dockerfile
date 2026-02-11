#syntax=docker/dockerfile:1.5.2

FROM ubuntu:22.04 AS build

ENV DEBIAN_FRONTEND=non-interactive
RUN apt-get update \
 && apt-get -y install --no-install-recommends \
        build-essential \
        ninja-build \
        git \
        ca-certificates \
        libglib2.0-dev \
        libfdt-dev \
        libpixman-1-dev \
        zlib1g-dev \
        python3-venv python3-pip python3-tomli \
        libmount-dev \
        libgcrypt20-dev zlib1g-dev autoconf automake libtool bison flex \
 && rm /usr/local/sbin/unminimize

ARG QEMU_VERSION=master
ARG TARGETS="aarch64-softmmu"
WORKDIR /tmp/qemu
RUN git clone -q --config advice.detachedHead=false --depth 1 --branch "${QEMU_VERSION}" https://github.com/chongdianbao/qemu .
WORKDIR /tmp/qemu/build
RUN ../configure --prefix=/usr/local --static --disable-user --disable-kvm --disable-xen --target-list="aarch64-softmmu" \
 && make
RUN make install

FROM scratch
COPY --from=build /usr/local/ /usr/local
