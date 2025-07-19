FROM alpine:3.16

RUN apk update
RUN apk upgrade

# Install dependencies
RUN apk add\
 build-base\
 git\
 glib-dev\
 meson\
 pkgconf\
 samurai

# Clone and build libslirp
RUN git clone https://gitlab.freedesktop.org/slirp/libslirp.git && \
 cd libslirp && \
 meson setup build --buildtype=release --default-library=static && \
 meson compile -C build && \
 meson install -C build

# Static lib now in:     libslirp/staging/usr/local/lib/libslirp.a
# Headers now in:        libslirp/staging/usr/local/include/

# required by qemu
RUN apk add\
 attr-dev attr\
 bison\
 bzip2-dev bzip2-static\
 flex\
 gcc\
 glib-dev glib-static\
 libc-dev\
 libcap-ng-dev libcap-ng-static\
 libvirt-dev libvirt-static\
 linux-headers\
 make\
 perl\
 pixman-dev pixman-static\
 pkgconf\
 py3-tomli\
 python3\
 zlib-dev zlib-static

# additional
RUN apk add bash xz git patch

WORKDIR /work

COPY command/base command/base
COPY command/fetch command/fetch
RUN /work/command/fetch

COPY command/extract command/extract
RUN /work/command/extract

COPY patch patch
COPY command/patch command/patch
RUN /work/command/patch

COPY command/configure command/configure
RUN /work/command/configure

COPY command/make command/make
RUN /work/command/make

COPY command/install command/install
RUN /work/command/install

COPY command/package command/package
RUN /work/command/package
