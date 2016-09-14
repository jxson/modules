MAKEFLAGS += --warn-undefined-variables --no-print-directory
SHELL := /bin/bash

# TODO(jxson): Add appropriate PATH based on deps/tools.

.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

DIRNAME := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
DEPS_DIR := third_party
FLUTTER_DIR := $(DEPS_DIR)/flutter
FLUTTER_BIN := $(DIRNAME)/$(DEPS_DIR)/flutter/bin
DART_BIN := $(FLUTTER_BIN)/cache/dart-sdk/bin
PATH := $(FLUTTER_BIN):$(DART_BIN):$(PATH)

################################################################################
## Common variables to use
gitbook = $(shell which gitbook)

DART_FILES = $(shell find . -name "*.dart" ! -wholename "./$(DEPS_DIR)/*" ! -wholename "./*/packages/*")
JS_FILES = $(shell find . -name "*.js" ! -wholename "./$(DEPS_DIR)/*" ! -wholename "*/node_modules/*")
SH_FILES = $(shell find ./tools -name "*.sh")
ALL_SOURCE_FILES = $(DART_FILES) $(JS_FILES) $(SH_FILES)

################################################################################
## Common targets
.PHONY: all
all: $(FLUTTER_DIR) ## Default task to build dependencies.
	@true

# SEE: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## Displays this help message.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "%-30s %s\n", $$1, $$2}'

.PHONY: init
init: ## Set path to pick up deps with: eval $(make init)
	@echo "export PATH=${PATH}"

.PHONY: build
build:
	@true

.PHONY: clean
clean:
	@true

.PHONY: copyright-check
copyright-check: ## Run the copyright checker.
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
	fi

.PHONY: depclean
depclean:
	@rm -rf $(FLUTTER_DIR)

.PHONY: fmt
fmt:
	@true

.PHONY: lint
lint:
	@true

# TODO(youngseokyoon): integrate this with the CI system later.
.PHONY: presubmit
presubmit: ## Run the presubmit tests.
	@$(MAKE) copyright-check

.PHONY: test
test:
	@true

.PHONY: coverage
coverage:
	@true

.PHONY: run
run: $(FLUTTER_DIR) ## Run the gallery flutter app.
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
## Dependencies
$(FLUTTER_DIR): FLUTTER_VERSION
	@$(MAKE) depclean
	git clone https://github.com/flutter/flutter.git $@
	cd $@ && git checkout $(shell echo -e `cat FLUTTER_VERSION`)
	flutter precache
	@touch $@
