#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

export LANG=C

KERNEL_VERSION="$1"
KERNEL_IMAGE="$2"

new-kernel-pkg --dracut --install "$KERNEL_VERSION"
