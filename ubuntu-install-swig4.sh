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

if apt-cache show swig4.0; then
  sudo apt-get install -y swig4.0
else
  mkdir swig
  pushd swig
  wget \
    "${UBUNTU_MIRROR}/pool/universe/s/swig/swig_${SWIG_VERSION}-${SWIG_BUILD}.dsc" \
    "${UBUNTU_MIRROR}/pool/universe/s/swig/swig_${SWIG_VERSION}.orig.tar.gz" \
    "${UBUNTU_MIRROR}/pool/universe/s/swig/swig_${SWIG_VERSION}-${SWIG_BUILD}.debian.tar.xz"
  sudo apt-get install -y bison debhelper dh-autoreconf dpkg-dev fakeroot libpcre3-dev

  dpkg-source -x "swig_${SWIG_VERSION}-${SWIG_BUILD}.dsc"

  pushd "swig-${SWIG_VERSION}"
  dpkg-buildpackage -rfakeroot -b
  popd

  sudo dpkg -i "swig_${SWIG_VERSION}-${SWIG_BUILD}_all.deb" "swig4.0_${SWIG_VERSION}-${SWIG_BUILD}_amd64.deb" ||
    sudo apt-get install -f
fi
