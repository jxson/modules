#!/bin/bash
# Copyright 2016 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$( dirname ${SCRIPT_DIR} )"

EXAMPLE_CONFIG_FILE=${REPO_DIR}/gallery/lib/src/config.example.dart
TARGET_CONFIG_FILE=${REPO_DIR}/gallery/lib/src/config.dart

# If the "config.dart" file does not exist or is older than the example
# config, copy the example config file to the target file.
if [ "${TARGET_CONFIG_FILE}" -ot "${EXAMPLE_CONFIG_FILE}" ]; then
    cp "${EXAMPLE_CONFIG_FILE}" "${TARGET_CONFIG_FILE}"
fi

PREFIX="${REPO_DIR}/email"

# If config.json files are missing create empty ones so the build doesn't
# break.
for name in email_flutter email_service; do
  CONFIG="${PREFIX}/${name}/assets/config.json"
  if [ ! -f "${CONFIG}" ]; then
    mkdir -p "$( dirname ${CONFIG} )"
    echo "{}" >> "${CONFIG}"
  fi
done
