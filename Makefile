# Copyright 2017 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Assumes that the project is located two levels deep in the Fuchsia tree, for
# example: $FUCHSIA_DIR/apps/<project>. Change to suit the project location.
root := $(shell git rev-parse --show-toplevel)
fuchsia_root := $(realpath $(root)/../..)
common_root := $(realpath $(fuchsia_root)/apps/modules/tools/common)
common_makfile := $(realpath $(common_root)/Makefile)

PROJECT := email

include $(common_makfile)
