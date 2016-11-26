# Copyright 2016 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

MAKEFLAGS += --warn-undefined-variables --no-print-directory
SHELL := /bin/bash

# TODO(jxson): Add appropriate PATH based on deps/tools.

.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

DIRNAME := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
FUCHSIA_ROOT := $(realpath $(DIRNAME)/../..)
FLUTTER_DIR := $(FUCHSIA_ROOT)/lib/flutter
FLUTTER_BIN := $(FLUTTER_DIR)/bin
DART_BIN := $(FLUTTER_BIN)/cache/dart-sdk/bin
OUT_DIR := $(FUCHSIA_ROOT)/out
GEN_DIR := $(OUT_DIR)/debug-x86-64/gen/apps/modules
MAGENTA_DIR := $(FUCHSIA_ROOT)/magenta
MAGENTA_BUILD_DIR := $(OUT_DIR)/build-magenta/build-magenta-pc-x86-64
PATH := $(FLUTTER_BIN):$(DART_BIN):$(PATH)

# Specify GOMA=1 to force use goma, GOMA=0 to force not use goma.
# Auto-detect if not specified.
FSET_FLAGS :=
GOMA ?=
ifeq ($(GOMA),1)
	GOMA_FLAGS += --goma
endif
ifeq ($(GOMA),0)
	GOMA_FLAGS += --no-goma
endif

FENV := source $(FUCHSIA_ROOT)/scripts/env.sh && fset x86-64 $(FSET_FLAGS)


################################################################################
## Common variables to use
gitbook = $(shell which gitbook)

FLUTTER_TEST_FLAGS ?=

DART_PACKAGES = $(shell find . -name "pubspec.yaml" -exec dirname {} \;)
DART_FILES = $(shell find . -name "*.dart" ! -wholename "*/.pub/*" ! -wholename "./*/packages/*")
DART_ANALYSIS_OPTIONS = $(addsuffix /.analysis_options, $(DART_PACKAGES))
JS_FILES = $(shell find . -name "*.js" ! -wholename "*/_book/*" ! -wholename "*/node_modules/*")
SH_FILES = $(shell find ./tools -name "*.sh")
GN_FILES = $(shell find . -name "*.gn")
FIDL_FILES = $(shell find . -name "*.fidl")
YAML_FILES = $(shell find . -name "*.yaml")
ALL_SOURCE_FILES = $(DART_FILES) $(JS_FILES) $(SH_FILES) $(GN_FILES) $(FIDL_FILES) $(YAML_FILES)

################################################################################
## Common targets
.PHONY: all
all: dart-base ## Default task to build dependencies.
	@true

# SEE: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## Displays this help message.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "%-20s %s\n", $$1, $$2}'

.PHONY: init
init: ## Set path to pick up deps with: eval $(make init)
	@echo "export PATH=${PATH}"

.PHONY: build
build:
	@true

.PHONY: clean
clean:
	@$(MAKE) dart-clean

.PHONY: copyright-check
copyright-check:
	@echo "** Checking the copyright headers ..."
	@export COPYRIGHT_ERROR=false; \
	for sf in $(ALL_SOURCE_FILES); do \
		if ! $$(tools/copyright_check.sh $${sf}); then \
			export COPYRIGHT_ERROR=true; \
			echo "Invalid copyright header: '$${sf}'"; \
		fi; \
	done; \
	if [ "$${COPYRIGHT_ERROR}" = true ]; then \
		exit 1; \
	else \
		echo "Done"; \
		echo; \
	fi

.PHONY: depclean
depclean:
	@rm -rf $(OUT_DIR)
	@rm -rf $(MAGENTA_BUILD_DIR)

.PHONY: fmt
fmt: ## Format everything.
	@$(MAKE) dart-fmt
	@$(MAKE) dart-fmt-extras

.PHONY: lint
lint: ## Lint everything.
	@$(MAKE) dart-lint

# TODO(youngseokyoon): integrate this with the CI system later.
.PHONY: presubmit
presubmit: ## Run the presubmit tests.
	@$(MAKE) build-fuchsia
	@$(MAKE) copyright-check
	@$(MAKE) dart-presubmit

.PHONY: test
test: ## Run tests for all modules.
	@$(MAKE) dart-test

.PHONY: coverage
coverage: ## Show coverage for all modules.
	@$(MAKE) dart-coverage

.PHONY: run
run: dart-base ## Run the gallery flutter app.
	@cd gallery && flutter run --hot

run-email: dart-base ## Run the email flutter app.
	@cd email/email_flutter && flutter run --hot

# TODO(jxson): Add gitbook as a third-party dependency.
.PHONY: doc
doc:
	@if [ -f "$(gitbook)" ]; then \
		gitbook install; \
		gitbook serve; \
	else \
		echo "The gitbook tool is required to view docs locally."; \
		echo ""; \
		echo "Install gitbook with npm:"; \
		echo ""; \
		echo "    npm install -g gitbook-cli"; \
		echo ""; \
	fi; \


################################################################################
## Dart specific targets
%/.packages: %/pubspec.yaml
	@echo "** Running 'flutter packages get' in package ./$* ..."
	@cd $* && flutter packages get
	@touch $*

# Each dart package needs the .analysis_options file so that the IDE can run the
# live analysis with the correct options.
$(DART_ANALYSIS_OPTIONS): $(DIRNAME)/.analysis_options
	cp $< $@

# Copy the example config file, if the config file does not exist.
EXAMPLE_CONFIG_FILE = gallery/lib/src/config.example.dart
TARGET_CONFIG_FILE = gallery/lib/src/config.dart

$(TARGET_CONFIG_FILE):
	cp $(EXAMPLE_CONFIG_FILE) $(TARGET_CONFIG_FILE)

.PHONY: dart-base
dart-base: build-fuchsia dart-symlinks $(addsuffix /.packages, $(DART_PACKAGES)) $(DART_ANALYSIS_OPTIONS) $(TARGET_CONFIG_FILE)
	@true

.PHONY: dart-symlinks
dart-symlinks:
	@$(FUCHSIA_ROOT)/scripts/symlink-dot-packages.py

.PHONY: dart-clean
dart-clean:
	@for pkg in $(DART_PACKAGES); do \
		pushd $${pkg} > /dev/null; \
		rm -rf .packages packages .pub build coverage; \
		popd > /dev/null; \
	done
	@rm -rf coverage

.PHONY: dart-coverage
dart-coverage:
	@FLUTTER_TEST_FLAGS='--coverage' $(MAKE) dart-test
	@echo
	@echo "** Code coverage for dart files **"
	@echo
	@tools/merge_coverage.sh
	@dart tools/report_coverage.dart coverage/lcov.info

.PHONY: dart-fmt
dart-fmt: dart-base
	@dartfmt -w $(DART_FILES)

.PHONY: dart-fmt-check
dart-fmt-check: dart-base
	@echo -n "** Checking the dart formatting ..."; \
	files=$$(dartfmt -n $(DART_FILES)); \
	if [[ $${files} ]]; then \
		echo; \
		echo "The following dart files are not correctly formatted:"; \
		for file in $${files}; \
		do \
			echo "$$file"; \
		done; \
		echo; \
		echo "Run \"make fmt\" to fix the formatting."; \
		exit 1; \
	else \
		echo "Done"; \
		echo; \
	fi

.PHONY: dart-fmt-extras
dart-fmt-extras:
	@cd tools/dartfmt_extras; \
	pub run bin/main.dart fix $(DIRNAME) $(DART_FILES)

.PHONY: dart-fmt-extras-check
dart-fmt-extras-check:
	@echo "** Checking for more dart formatting issues ..."
	@cd tools/dartfmt_extras; \
	pub run bin/main.dart check $(DIRNAME) $(DART_FILES); \
	if [ $$? -ne 0 ] ; then \
		echo; \
		echo "The above dart files have formatting issues."; \
		echo "Run \"make fmt\" to fix the formatting."; \
		echo; \
		exit 1; \
	else \
		echo "Done"; \
		echo; \
	fi

.PHONY: dart-lint
dart-lint: dart-base
	@for pkg in $(DART_PACKAGES); do \
		echo "** Running the dartanalyzer in '$${pkg}' ..."; \
		pushd $${pkg} > /dev/null; \
		dartanalyzer --lints --fatal-lints --fatal-warnings . || exit 1; \
		popd > /dev/null; \
		echo; \
	done

.PHONY: dart-test
dart-test: dart-base
	@for pkg in $(DART_PACKAGES); do \
		echo; \
		pushd $${pkg} > /dev/null; \
		if [ -d "test" ]; then \
			echo "** Running the flutter tests in '$${pkg}' ..."; \
			flutter test $(FLUTTER_TEST_FLAGS) || exit 1; \
		else \
			echo "** No tests found in '$${pkg}'."; \
		fi; \
		popd > /dev/null; \
	done

.PHONY: dart-presubmit
dart-presubmit:
	@$(MAKE) dart-fmt-check
	@$(MAKE) dart-fmt-extras-check
	@$(MAKE) dart-lint
	@$(MAKE) dart-coverage

################################################################################
## Email related targets
.PHONY: auth
auth: email/config.json ## Update email auth credentials with a refresh token.
	@cd email/tools; \
	pub run bin/oauth.dart
	@for dir in email/email_flutter/assets email/email_service/assets email/map/assets email/usps/assets email/youtube_related_videos/assets email/youtube_video/assets; do \
		mkdir -p $${dir}; \
		cp email/config.json $${dir}/config.json; \
	done

email/config.json:
	@echo "{}" >> email/config.json
	@echo "==> Config file added."
	@echo "==> Add missing values and run: make auth."

################################################################################
## Fuchsia related targets
.PHONY: build-fuchsia
build-fuchsia: ## Build Fuchsia.
	@$(FENV) && fbuild
