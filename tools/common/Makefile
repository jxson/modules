# Copyright 2017 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

MAKEFLAGS += --warn-undefined-variables --no-print-directory
SHELL := /bin/bash

.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

# This Makefile is expected to be included in a parent Makefile for a given
# project. In order for the conventions used by the tasks defined in this file
# a PROJECT variable must be set, for example:
#
#     PROJECT := <project>
#
#     include <path to this Makefile>
#
ifndef PROJECT
$(error PROJECT is not set. \
Before including the common Makefile add "PROJECT := <project>" to \
"$(firstword $(realpath $(MAKEFILE_LIST)))")
endif

root ?= $(shell git rev-parse --show-toplevel)
fuchsia_root ?= $(realpath $(root)/../..)
common_root ?= $(realpath $(fuchsia_root)/apps/modules/tools/common)
fuchsia_out := $(realpath $(fuchsia_root)/out)
flutter_bin := $(fuchsia_root)/lib/flutter/bin
dart_bin := $(flutter_bin)/cache/dart-sdk/bin
flutter := $(flutter_bin)/flutter
sources := $(shell find $(root) \
    -name "*.dart" \
    -o -name "*.py" \
    -o -name "*.fidl" \
    -o -name "*.gn" \
    -o -name "*.sh" \
    -o -name "*.yaml")
makefiles := $(foreach file, $(MAKEFILE_LIST), $(realpath $(file)))

PATH := $(flutter_bin):$(dart_bin):$(PATH)

PHONY: all
all: build

PHONY: build
build: ## Build Fuchsia with project.
	@FUCHSIA_DIR=$(fuchsia_root) $(common_root)/build.sh

PHONY: reboot
reboot: ## Reboot connected Fuchsia device.
	@FUCHSIA_DIR=$(fuchsia_root) $(common_root)/reboot.sh

PHONY: run
run: ## Run project on Fuchsia.
	@echo "=== Don't forget to reboot between builds! ==="
	@FUCHSIA_DIR=$(fuchsia_root) $(common_root)/run.sh $(PROJECT)

PHONY: flutter-run
flutter-run: ## Run UI application in modules/<project> via `flutter run`.
	cd $(root)/modules/$(PROJECT) && \
		$(flutter) upgrade && \
		$(flutter) build clean && \
		$(flutter) run --hot

PHONY: dart-lint
dart-lint: build
	$(fuchsia_root)/scripts/run-dart-analysis.py \
			--out=$(fuchsia_out)/debug-x86-64 \
			--tree=//apps/$(PROJECT)/* \
			--lints --fatal-lints --fatal-warnings

.PHONY: dart-fmt
dart-fmt: $(dart_bin)
	@dartfmt -w $(shell find $(root) -name "*.dart")

PHONY: copyright-check
copyright-check: ## Check source files for missing copyright.
	@$(common_root)/copyright-check.sh $(sources)

.PHONY: help
help: ## Displays this help message.
	@for file in $(makefiles); do \
		grep -E '^[a-zA-Z_-]+:.*?## .*$$' $${file} | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "%-20s %s\n", $$1, $$2}'; \
	done
