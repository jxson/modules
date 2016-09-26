MAKEFLAGS += --warn-undefined-variables --no-print-directory
SHELL := /bin/bash

# TODO(jxson): Add appropriate PATH based on deps/tools.

.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

DIRNAME := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
DEPS_DIR := third_party
SYSUI_DEPS_DIR := $(realpath $(DIRNAME)/../sysui/third_party)
FLUTTER_DIR := $(SYSUI_DEPS_DIR)/flutter
FLUTTER_BIN := $(FLUTTER_DIR)/bin
DART_BIN := $(FLUTTER_BIN)/cache/dart-sdk/bin
PATH := $(FLUTTER_BIN):$(DART_BIN):$(PATH)

################################################################################
## Common variables to use
gitbook = $(shell which gitbook)

FLUTTER_TEST_FLAGS ?=

DART_PACKAGES = $(shell find . -name "pubspec.yaml" ! -wholename "./$(DEPS_DIR)/*" -exec dirname {} \;)
DART_FILES = $(shell find . -name "*.dart" ! -wholename "./$(DEPS_DIR)/*" ! -wholename "*/.pub/*" ! -wholename "./*/packages/*")
JS_FILES = $(shell find . -name "*.js" ! -wholename "./$(DEPS_DIR)/*" ! -wholename "*/_book/*" ! -wholename "*/node_modules/*")
SH_FILES = $(shell find ./tools -name "*.sh")
ALL_SOURCE_FILES = $(DART_FILES) $(JS_FILES) $(SH_FILES)

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
		echo $${sf}; \
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
	@true

.PHONY: fmt
fmt: ## Format everything.
	@$(MAKE) dart-fmt
	@$(MAKE) dart-fmt-quotes

.PHONY: lint
lint: ## Lint everything.
	@$(MAKE) dart-lint

# TODO(youngseokyoon): integrate this with the CI system later.
.PHONY: presubmit
presubmit: ## Run the presubmit tests.
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
%/packages: %/pubspec.yaml
	@echo "** Running pub get in package ./$* ..."
	@cd $* && pub get
	@touch $*

.PHONY: dart-base
dart-base: $(addsuffix /packages, $(DART_PACKAGES))
	@true

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

.PHONY: dart-fmt-quotes
dart-fmt-quotes:
	@# Need to create a temporary backup file to deal with some quirks in sed tool
	@# between Linux and Darwin.
	@# See: http://stackoverflow.com/questions/5694228
	@for file in $(DART_FILES); do \
		sed -E -i.bak-quotes "s/\"([^']*)\"/\'\1\'/g" $$file; \
		rm $${file}.bak-quotes; \
	done

.PHONY: dart-fmt-quotes-check
dart-fmt-quotes-check:
	@echo "** Checking double-quotes in dart source files ..."
	@export QUOTE_ERROR=false; \
	for file in $(DART_FILES); do \
		grep --color=auto -rnEH "\"[^']*\"" $$file && export QUOTE_ERROR=true; \
	done; \
	if [ "$${QUOTE_ERROR}" = true ]; then \
		echo; \
		echo "The above files have double-quoted strings."; \
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
		dartanalyzer --lints --fatal-lints \
			--options $(DIRNAME)/.analysis_options . || exit 1; \
		popd > /dev/null; \
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
	@$(MAKE) dart-fmt-quotes-check
	@$(MAKE) dart-lint
	@$(MAKE) dart-coverage
