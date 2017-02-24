#!/bin/bash
# Copyright 2017 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Exit this script if one command fails.
set -e

# TODO(jasoncampbell): Do something a little better than requiring an env var
# to be set.
source "${FUCHSIA_DIR}/scripts/env.sh"

function usage() {
  echo "Usage: `basename $0` <package>"
  exit 1
}

function main() {
  local package=$1

  if [[ $# -ne 1 ]]; then
    usage
  fi

  echo "=== running ${package}"

  $FUCHSIA_DIR/out/build-magenta/tools/netruncmd : "@ bootstrap device_runner --user_shell=dev_user_shell --user_shell_args=--root_module=${package}"
}

main "$@"
