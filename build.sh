#!/usr/bin/env bash

set -ex

readonly ARCHITECTURE=$1

cd "$(dirname "$0")"

readonly SCRIPT_DIRECTORY="$PWD"
readonly BUILD_DIRECTORY="${SCRIPT_DIRECTORY}/mono-src"

cd "${BUILD_DIRECTORY}"

case "$ARCHITECTURE" in
  linux-arm)
    ./autogen.sh \
      --build=x86_64-linux-gnu \
      --host=arm-linux-gnueabihf
    ;;
  linux-arm64)
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
  osx-arm64)
    CC=clang CXX=clang++ CFLAGS="-mmacosx-version-min=13.0" ./autogen.sh
    ;;
  osx-x64)
    CC=clang CXX=clang++ CFLAGS="-mmacosx-version-min=10.13" ./autogen.sh \
      --build=aarch64-apple-darwin20.6.0 \
      --host=x86_64-apple-darwin20.6.0
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

case "$ARCHITECTURE" in
  linux-arm)
    arm-linux-gnueabihf-strip --strip-all .libs/libMonoPosixHelper.so
    ;;
  linux-arm64)
    aarch64-linux-gnu-strip --strip-all .libs/libMonoPosixHelper.so
    ;;
  linux-x86)
    i686-linux-gnu-strip --strip-all .libs/libMonoPosixHelper.so
    ;;
  osx-*)
    strip -S .libs/libMonoPosixHelper.dylib
    ;;
  *)
    strip --strip-all .libs/libMonoPosixHelper.so
    ;;
esac
