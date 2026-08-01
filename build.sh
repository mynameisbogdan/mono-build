#!/usr/bin/env bash

set -ex

readonly ARCHITECTURE=$1

cd "$(dirname "$0")"

readonly SCRIPT_DIRECTORY="$PWD"
readonly BUILD_DIRECTORY="${SCRIPT_DIRECTORY}/mono-src"

cd "${BUILD_DIRECTORY}"

STRIP_CMD="strip --strip-all"

case "$ARCHITECTURE" in
  linux-arm)
    STRIP_CMD="arm-linux-gnueabihf-strip --strip-all"

    ./autogen.sh \
      --build=x86_64-linux-gnu \
      --host=arm-linux-gnueabihf
    ;;
  linux-arm64)
    STRIP_CMD="aarch64-linux-gnu-strip --strip-all --strip-all"

    ./autogen.sh \
      --build=x86_64-linux-gnu \
      --host=aarch64-linux-gnu
    ;;
  linux-x64)
    ./autogen.sh \
      --build=x86_64-linux-gnu \
      --host=x86_64-linux-gnu
    ;;
  linux-x86)
    STRIP_CMD="i686-linux-gnu-strip --strip-all"

    ./autogen.sh \
      --build=x86_64-linux-gnu \
      --host=i686-linux-gnu
    ;;
  linux-musl-x64 | linux-musl-arm64)
    ./autogen.sh
    ;;
  freebsd-x64 | freebsd-arm64)
    CC=clang CXX=clang++ ./autogen.sh
    ;;
  *)
    echo "Unsupported architecture $ARCHITECTURE"
    exit 1
    ;;
esac

cd "${BUILD_DIRECTORY}/mono/eglib"
make

cd "${BUILD_DIRECTORY}/mono/zlib"
make

cd "${BUILD_DIRECTORY}/support"
make

$STRIP_CMD .libs/libMonoPosixHelper.so
