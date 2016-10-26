#!/bin/bash
# Copyright 2016 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$( dirname ${SCRIPT_DIR} )"

EXAMPLE_CONFIG_FILE=${REPO_DIR}/gallery/lib/src/config.example.dart
TARGET_CONFIG_FILE=${REPO_DIR}/gallery/lib/src/config.dart

# If the "config.dart" file does not exist in gallery, copy the example file.
if [ ! -f "${TARGET_CONFIG_FILE}" ]; then
    cp "${EXAMPLE_CONFIG_FILE}" "${TARGET_CONFIG_FILE}"
fi
