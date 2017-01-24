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
MAGENTA_BUILD_DIR := $(OUT_DIR)/build-magenta/build-magenta-pc-x86-64
PATH := $(FLUTTER_BIN):$(DART_BIN):$(PATH)

# Specify GOMA=1 to force use goma, GOMA=0 to force not use goma.
# Auto-detect if not specified.
FSET_FLAGS :=
GOMA ?=
ifeq ($(GOMA),1)
	FSET_FLAGS += --goma
endif
ifeq ($(GOMA),0)
	FSET_FLAGS += --no-goma
endif

GOMA_DIR ?=
ifneq ($(strip $(GOMA_DIR)),)
	FSET_FLAGS += --goma-dir $(GOMA_DIR)
endif

# If NO_ENSURE_GOMA=1 then we tell fbuild not to run the goma script directly.
NO_ENSURE_GOMA ?=
ifeq ($(NO_ENSURE_GOMA),1)
	FSET_FLAGS += --no-ensure-goma
endif

# If MINIMAL=1 then we perform a minimal build of only the "modules" package and
# its dependencies.
MINIMAL ?=
ifeq ($(MINIMAL),1)
	FSET_FLAGS += --modules modules
endif

# TODO(armansito): Remove this TODO line as part of a CL to test the CQ.

# Respect the fuchsia build variant if already set by fset command externally.
# Otherwise, default to debug build.
FUCHSIA_VARIANT ?= debug
ifeq ($(FUCHSIA_VARIANT),release)
	FSET_FLAGS += --release
endif

FENV := source $(FUCHSIA_ROOT)/scripts/env.sh && fset x86-64 $(FSET_FLAGS)

DART_ANALYSIS_FLAGS := --lints --fatal-lints --fatal-warnings

################################################################################
## Common variables to use
gitbook = $(shell which gitbook)

DART_PACKAGES = $(sort $(shell find . \( -name "pubspec.yaml" -or -name ".packages" \) ! -wholename "*/testdata/*" -exec dirname {} \;))
DART_FILES = $(shell find . -name "*.dart" ! -wholename "*/.pub/*" ! -wholename "./*/packages/*" ! -wholename "*/testdata/*" ! -wholename "*/generated/*")
DART_ANALYSIS_OPTIONS = $(addsuffix /.analysis_options, $(DART_PACKAGES))
FIDL_FILES = $(shell find . -name "*.fidl")
GN_FILES = $(shell find . -name "*.gn")
JS_FILES = $(shell find . -name "*.js" ! -wholename "*/_book/*" ! -wholename "*/node_modules/*")
PYTHON_FILES = $(shell find . -name "*.py" ! -wholename "./infra/*")
SH_FILES = $(shell find ./tools -name "*.sh")
YAML_FILES = $(shell find . -name "*.yaml" ! -wholename "*/testdata/*")
ALL_SOURCE_FILES = $(DART_FILES) $(FIDL_FILES) $(GN_FILES) $(JS_FILES) $(PYTHON_FILES) $(SH_FILES) $(YAML_FILES)

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
clean: dart-clean
	@true

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
fmt: dart-fmt dart-fmt-extras ## Format everything.
	@true

.PHONY: lint
lint: dart-lint ## Lint everything.
	@true

# TODO(youngseokyoon): integrate this with the CI system later.
.PHONY: presubmit
presubmit: build-fuchsia copyright-check dart-presubmit ## Run the presubmit tests.
	@true

.PHONY: test
test: dart-test ## Run tests for all modules.
	@true

.PHONY: coverage
coverage: dart-coverage ## Show coverage for all modules.
	@true

.PHONY: run
run: dart-gen-specs ## Run the gallery flutter app.
	@if [ -L "gallery/.packages" ]; then \
		rm gallery/.packages; \
	fi;
	@cd gallery && flutter run --hot

run-email: ## Run the email flutter app.
	@if [ -L "email/email_flutter/.packages" ]; then \
		rm email/email_flutter/.packages; \
	fi;
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

$(DART_BIN):
	@flutter precache

# Each dart package needs the .analysis_options file so that the IDE can run the
# live analysis with the correct options.
$(DART_ANALYSIS_OPTIONS): $(DIRNAME)/.analysis_options
	cp $< $@

.PHONY: dart-base
dart-base: build-fuchsia dart-symlinks $(addsuffix /.packages, $(DART_PACKAGES)) $(DART_ANALYSIS_OPTIONS)
	@true

.PHONY: dart-symlinks
dart-symlinks:
	@$(FUCHSIA_ROOT)/scripts/symlink-dot-packages.py --tree=//apps/modules/*

.PHONY: dart-clean
dart-clean:
	@for pkg in $(DART_PACKAGES); do \
		pushd $${pkg} > /dev/null; \
		rm -rf .packages packages .pub build coverage; \
		popd > /dev/null; \
	done
	@rm -rf gallery/lib/src/generated/*.dart
	@rm -rf coverage

.PHONY: dart-gen-specs
dart-gen-specs: $(DART_BIN) tools/widget_specs/.packages packages/widgets/.packages
	@rm -rf gallery/lib/src/generated/*.dart
	@cd tools/widget_specs && \
	pub run gen_widget_specs.dart \
		$(DIRNAME)/packages/widgets \
		$(DIRNAME)/gallery/lib/src/generated \
		$(FUCHSIA_ROOT)

.PHONY: dart-coverage
dart-coverage: dart-base
	@tools/run_dart_tests.py --coverage
	@$(MAKE) dart-report-coverage

.PHONY: dart-report-coverage
dart-report-coverage:
	@echo
	@echo "** Code coverage for dart files **"
	@echo
	@tools/merge_coverage.sh
	@dart tools/report_coverage.dart coverage/lcov.info

.PHONY: dart-fmt
dart-fmt: $(DART_BIN)
	@dartfmt -w $(DART_FILES)

.PHONY: dart-fmt-check
dart-fmt-check: $(DART_BIN)
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
dart-fmt-extras: $(DART_BIN) tools/dartfmt_extras/.packages
	@cd tools/dartfmt_extras; \
	pub run bin/main.dart fix $(DIRNAME) $(DART_FILES)

.PHONY: dart-fmt-extras-check
dart-fmt-extras-check: $(DART_BIN) tools/dartfmt_extras/.packages
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
	@# First run the fuchsia dart analysis tool to analyze all dart packages
	@# with BUILD.gn files.
	@$(FUCHSIA_ROOT)/scripts/run-dart-analysis.py \
			--out=$(OUT_DIR)/$(FUCHSIA_VARIANT)-x86-64 \
			--tree=//apps/modules/* \
			$(DART_ANALYSIS_FLAGS)
	@# Next, run the dartanalyzer for regular dart packages without BUILD.gn
	@for pkg in $(DART_PACKAGES); do \
		if [ -e $${pkg}/BUILD.gn ]; then continue; fi; \
		echo "** Running the dartanalyzer in '$${pkg}' ..."; \
		pushd $${pkg} > /dev/null; \
		dartanalyzer $(DART_ANALYSIS_FLAGS) . || exit 1; \
		popd > /dev/null; \
		echo; \
	done

.PHONY: dart-test
dart-test: dart-base
	@tools/run_dart_tests.py

.PHONY: dart-presubmit
dart-presubmit: dart-gen-specs dart-fmt-check dart-fmt-extras-check dart-lint dart-test
	@true

################################################################################
## Email related targets
.PHONY: auth
auth: email/config.json ## Update email auth credentials with a refresh token.
	@cd email/tools; \
	pub run bin/oauth.dart
	@for dir in email/email_flutter/assets email/email_service/assets email/map/assets email/usps/assets email/youtube_related_videos/assets email/youtube_video/assets gallery/assets; do \
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
