#!/bin/bash
# Copyright 2017 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Exit this script if one command fails.
set -e

# TODO(jasoncampbell): Do something a little better than requiring an env var
# to be set.
source "${FUCHSIA_DIR}/scripts/env.sh"

function main() {
  echo "=== buidling Fuchsia"

  fset x86-64 $@
  fbuild
}

main "$@"
