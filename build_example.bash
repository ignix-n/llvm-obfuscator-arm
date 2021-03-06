#!/usr/bin/env bash

# Copyright (C) 2017 Swift Navigation Inc.
# Contact: Swift Navigation <dev@swiftnav.com>
#
# This source is subject to the license found in the file 'LICENSE' which must
# be be distributed together with this source. All other rights reserved.
#
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

set -euo pipefail
IFS=$'\n\t'

DOCKER_NAMETAG=$(cat docker_nametag)
BR2_TOOLCHAIN_LD_LIBRARY_PATH=/toolchain/x86/x86_64-buildroot-linux-gnu/lib64

mkdir -p output/opt

NO_TTY=

while [[ $# -gt 0 ]]; do
  case $1 in
  --no-tty)
  NO_TTY=y
  shift
  ;;
  *) shift ;;
  esac
done

if [[ -z "$NO_TTY" ]]; then
  INTERACTIVE=("-i" "-t")
else
  INTERACTIVE=()
fi

# shellcheck disable=SC2068
docker run ${INTERACTIVE[@]:-} --rm \
    -v "$PWD/example:/work/example" \
    -v "$PWD/output/opt:/opt" \
    -v obfuscator-llvm:/work/obfuscator-llvm \
    -v obfuscator-llvm-build:/work/build \
    -e BR2_TOOLCHAIN_PATH=/toolchain/arm \
    "$DOCKER_NAMETAG" \
    /bin/bash -c "export PATH=/opt/llvm-obfuscator/bin:/opt/llvm-obfuscator/wrappers/bin:\$PATH; \
                  export BR2_TOOLCHAIN_PATH=/toolchain/arm; \
                  export BR2_TOOLCHAIN_LD_LIBRARY_PATH=$BR2_TOOLCHAIN_LD_LIBRARY_PATH; \
                  make -C example"
