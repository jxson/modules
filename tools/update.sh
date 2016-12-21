#!/bin/bash
# Copyright 2016 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$( dirname ${SCRIPT_DIR} )"

# If config.json files are missing create empty ones so the build doesn't
# break.
for name in email/email_flutter email/email_service email/map email/usps email/youtube_related_videos email/youtube_video gallery; do
  CONFIG="${REPO_DIR}/${name}/assets/config.json"
  if [ ! -f "${CONFIG}" ]; then
    mkdir -p "$( dirname ${CONFIG} )"
    echo "{}" >> "${CONFIG}"
  fi
done
