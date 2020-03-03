#!/usr/bin/env bash

# Copyright 2020 Simon Dierl <simon.dierl@cs.tu-dortmund.de>
# SPDX-License-Identifier: ISC
#
# Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby
# granted, provided that the above copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
# AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

set -euxo pipefail

abort-if-missing() {
  if [ -z "${!1}" ]; then
    echo "No ${1} environment variable provided. Aborting." >&2
    exit 1
  fi
}

prepare-macOS-latest() {
  brew install automake coreutils
  export PATH="/usr/local/opt/coreutils/libexec/gnubin:${PATH}"
}

prepare-local() { true; }

prepare-ubuntu-latest() {
  if apt-cache show swig4.0; then
    sudo apt-get install -y swig4.0
  else
    abort-if-missing UBUNTU_MIRROR
    abort-if-missing UBUNTU_SWIG_BUILD
    abort-if-missing UBUNTU_SWIG_VERSION
    prepare-swig-source "${UBUNTU_MIRROR}" "${UBUNTU_SWIG_VERSION}" "${UBUNTU_SWIG_VERSION}-${UBUNTU_SWIG_BUILD}"
    build-swig-deb "${UBUNTU_SWIG_VERSION}"
    install-swig-deb "${UBUNTU_SWIG_VERSION}-${UBUNTU_SWIG_BUILD}"
  fi
}

prepare-swig-source() {
  mkdir swig
  pushd swig
  wget \
    "${1}/pool/universe/s/swig/swig_${3}.dsc" \
    "${1}/pool/universe/s/swig/swig_${2}.orig.tar.gz" \
    "${1}/pool/universe/s/swig/swig_${3}.debian.tar.xz"
  sudo apt-get install -y bison debhelper dh-autoreconf dpkg-dev fakeroot libpcre3-dev

  dpkg-source -x "swig_${3}.dsc"
  popd
}

build-swig-deb() {
  pushd "swig/swig-${1}"
  dpkg-buildpackage -rfakeroot -b
  popd
}

install-swig-deb() {
  sudo dpkg -i "swig/swig_${1}_all.deb" "swig/swig4.0_${1}_amd64.deb" || sudo apt-get install -f
}

prepare-cvc4() {
  git clone https://github.com/CVC4/CVC4.git --branch "${1}" src
  pushd src
  git apply --ignore-space-change --ignore-whitespace "${2}"
  popd
}

install-dependencies() {
  pushd src
  # GMP is required by CLN
  for dependency in abc antlr-3.4 cadical gmp cln cryptominisat drat2er glpk-cut-log lfsc-checker symfpu; do
    contrib/get-$dependency
  done
  popd
}

install-cvc4() {
  FLAGS=(--abc --cadical --cryptominisat --drat2er --lfsc --symfpu "--language-bindings=java"
    "--name=build-${2}" "--prefix=${1}")
  GPL_FLAGS=(--gpl --cln --glpk)

  pushd src
  case "${2}" in
  gpl)
    ./configure.sh "${FLAGS[@]}" "${GPL_FLAGS[@]}"
    ;;
  permissive)
    ./configure.sh "${FLAGS[@]}"
    ;;
  esac

  pushd "build-${2}"
  make -j "$(nproc)" install
  popd

  popd
}

postprocess-cvc4() {
  pushd "${1}/lib"
  for file in *.dylib *.jnilib; do
    install_name_tool \
      -change '@rpath/libcvc4.6.dylib' '@loader_path/libcvc4.6.dylib' \
      -change '@rpath/libcvc4parser.6.dylib' '@loader_path/libcvc4parser.6.dylib' "${file}"
  done
  strip -s -- *.dylib *.jnilib *.so
  popd
}

abort-if-missing CVC4_VERSION

if [ -z "${BUILD_NAME}" ]; then
  echo "No BUILD_NAME environment variable provided. Preparation will be skipped." >&2
  export BUILD_NAME=local
fi

"prepare-${BUILD_NAME}"
prepare-cvc4 "${CVC4_VERSION}" "$(pwd)/cvc4-${CVC4_VERSION}.patch"
install-dependencies
install-cvc4 "$(pwd)/build/cvc4-${CVC4_VERSION}-${BUILD_NAME}-gpl" gpl
postprocess-cvc4 "$(pwd)/build/cvc4-${CVC4_VERSION}-${BUILD_NAME}-gpl"
install-cvc4 "$(pwd)/build/cvc4-${CVC4_VERSION}-${BUILD_NAME}-permissive" permissive
postprocess-cvc4 "$(pwd)/build/cvc4-${CVC4_VERSION}-${BUILD_NAME}-permissive"
