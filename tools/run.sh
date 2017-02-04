#!/bin/bash
# Copyright 2017 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Exit this script if one command fails.
set -e

readonly TREE_ROOT=`git rev-parse --show-toplevel`
readonly FUCHSIA_ROOT="$(dirname $(dirname "${TREE_ROOT}"))"

source "${FUCHSIA_ROOT}/scripts/env.sh"

netruncmd : "@ bootstrap device_runner --user_shell=dev_user_shell --user_shell_args=--root_module=email"
