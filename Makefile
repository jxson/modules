# Copyright 2017 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

MAKEFLAGS += --warn-undefined-variables --no-print-directory
SHELL := /bin/bash

.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

root := $(shell pwd)
fuchsia_root := $(realpath $(root)/../..)
fuchsia_out := $(realpath $(fuchsia_root)/out)
flutter_bin := $(fuchsia_root)/lib/flutter/bin
flutter := $(flutter_bin)/flutter
sources := $(shell find $(root) \
    -name "*.dart" \
    -o -name "*.fidl" \
    -o -name "*.gn" \
    -o -name "*.sh" \
    -o -name "*.yaml")

PHONY: all
all: build

PHONY: build
build: ## Build Fuchsia (including this app).
	./tools/build.sh

PHONY: test
test: ## Run the tests.
	@true

PHONY: test
presubmit: lint test

PHONY: run
run: ## Run on Fuchsia.
	./tools/run.sh

PHONY: lint
lint: dart-lint copyright-check ## Lint the code.

PHONY: flutter
flutter-run: ## Run via `flutter run`.
	# TODO(jasoncampbell): Trap and remove .packages when this process is
	# done.
	cd $(root)/modules/chat && \
		$(flutter) upgrade && \
		$(flutter) build clean && \
		$(flutter) run --hot

PHONY: dart-lint
dart-lint: build
	$(fuchsia_root)/scripts/run-dart-analysis.py \
			--out=$(fuchsia_out)/debug-x86-64 \
			--tree=//apps/chat/* \
			--lints --fatal-lints --fatal-warnings

PHONY: copyright-check
copyright-check: ## Check source files for missing copyright.
	@./tools/copyright-check.sh $(sources)

.PHONY: help
help: ## Displays this help message.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "%-20s %s\n", $$1, $$2}'
