#!/bin/bash
# Copyright 2016 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# This script is meant to be run as part of the 'jiri update' process.
# Make sure to add this script as the runhook for this repository.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$( dirname ${DIR} )"
DEPS_DIR=third_party
FLUTTER_DIR=${PARENT_DIR}/${DEPS_DIR}/flutter
FLUTTER_BIN=${FLUTTER_DIR}/bin
FLUTTER_VERSION_FILE=${PARENT_DIR}/FLUTTER_VERSION

# If the flutter directory exists and it is newer than the FLUTTER_VERSION file,
# do not update the flutter directory and exit immediately.
if  [ -d "${FLUTTER_DIR}" ] && \
    [ "${FLUTTER_DIR}" -nt "${FLUTTER_VERSION_FILE}" ]; then
    exit 0
fi

# Update the flutter tools.
rm -rf ${FLUTTER_DIR}
git clone https://github.com/flutter/flutter.git ${FLUTTER_DIR}
cd ${FLUTTER_DIR} && git checkout $(cat ${FLUTTER_VERSION_FILE})
${FLUTTER_BIN}/flutter precache
touch ${FLUTTER_DIR}
