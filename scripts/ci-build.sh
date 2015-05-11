#!/bin/bash

set -e

autotools_build() {
  autoreconf -i
  ./configure --prefix=$PWD/_install
  make
  make install
}

cmake_build() {
  mkdir _build
  cd _build
  cmake .. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$PWD/_install
  cmake --build . --target install
}

scan_build() {
  REPORT_DIR="$PWD/_build/$(git describe)_report"
  mkdir -p $REPORT_DIR
  cd $PWD/_build
  scan-build cmake .. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$PWD/_install
  scan-build cmake --build . --target install
}

case "$1" in
  autotools )
    autotools_build
    ;;
  cmake )
    case "$CC" in
      clang )
        CFLAGS="-Werror -fsanitize=undefined"
    esac
    cmake_build
    ;;
  asan )
    CFLAGS="-fsanitize=address"
    cmake_build
    ;;
  tsan )
    CFLAGS="-fsanitize=thread"
    cmake_build
    ;;
  scan-build )
    scan_build
    ;;
  * )
    echo "Usage: $0 {autotools|cmake|asan|tsan|scan-build}"
    exit 1
esac
