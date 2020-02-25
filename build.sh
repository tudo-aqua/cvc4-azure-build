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

CVC4_VERSION=1.7

prefix="$(pwd)/build"
patch="$(pwd)/cvc4-${CVC4_VERSION}.patch"

git clone https://github.com/CVC4/CVC4.git --branch ${CVC4_VERSION} src
pushd src

git apply "${patch}"

for dependency in antlr-3.4 gmp abc cadical cln cryptominisat drat2er glpk-cut-log lfsc-checker symfpu; do
  contrib/get-$dependency
done

./configure.sh --gpl \
  --abc --cadical --cln --cryptominisat --drat2er --lfsc --glpk --symfpu \
  --language-bindings=java --prefix="${prefix}"
pushd build
make -j "$(nproc)" install
popd

popd
