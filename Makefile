MAKEFLAGS += --warn-undefined-variables --no-print-directory
SHELL := /bin/bash

# TODO(jxson): Add appropriate PATH based on deps/tools.

.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

DIRNAME := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
DEPS_DIR := third_party
FLUTTER_DIR := $(realpath $(DIRNAME)/../lib/flutter)
FLUTTER_BIN := $(FLUTTER_DIR)/bin
DART_BIN := $(FLUTTER_BIN)/cache/dart-sdk/bin
OUT_DIR := $(abspath $(DIRNAME)/../out)
GEN_DIR := $(OUT_DIR)/debug-x86-64/gen
MAGENTA_BUILD_DIR := $(abspath $(DIRNAME)/../magenta/build-magenta-pc-x86-64)
PATH := $(FLUTTER_BIN):$(DART_BIN):$(PATH)


################################################################################
## Common variables to use
gitbook = $(shell which gitbook)

FLUTTER_TEST_FLAGS ?=

DART_PACKAGES = $(shell find . -name "pubspec.yaml" ! -wholename "./$(DEPS_DIR)/*" -exec dirname {} \;)
DART_FILES = $(shell find . -name "*.dart" ! -wholename "./$(DEPS_DIR)/*" ! -wholename "*/.pub/*" ! -wholename "./*/packages/*" ! -name "*.mojom.dart")
DART_ANALYSIS_OPTIONS = $(addsuffix /.analysis_options, $(DART_PACKAGES))
JS_FILES = $(shell find . -name "*.js" ! -wholename "./$(DEPS_DIR)/*" ! -wholename "*/_book/*" ! -wholename "*/node_modules/*")
SH_FILES = $(shell find ./tools -name "*.sh")
GN_FILES = $(shell find . -name "*.gn" ! -wholename "./$(DEPS_DIR)/*")
MOJOM_FILES = $(shell find . -name "*.mojom" ! -wholename "./$(DEPS_DIR)/*")
ALL_SOURCE_FILES = $(DART_FILES) $(JS_FILES) $(SH_FILES) $(GN_FILES) $(MOJOM_FILES)

MOJOM_DART_OUTPUTS = $(abspath $(addsuffix .dart,$(addprefix $(GEN_DIR)/modules/,$(MOJOM_FILES))))
MOJOM_DART_SYMLINKS = $(join $(addsuffix lib/, $(dir $(MOJOM_FILES))), $(addsuffix .mojom.dart, $(basename $(notdir $(MOJOM_FILES)))))

ifeq ($(wildcard ~/goma/.*),)
	GOMA_INSTALLED := no
	GEN_FLAGS :=
	NINJA_FLAGS := -j32
else
	GOMA_INSTALLED := yes
	GEN_FLAGS := --goma
	NINJA_FLAGS := -j1000
endif

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
	@$(MAKE) mojom-clean

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
dart-base: $(addsuffix /.packages, $(DART_PACKAGES)) $(DART_ANALYSIS_OPTIONS) $(TARGET_CONFIG_FILE) mojom-gen
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

# When running dartanalyzer, we need to specify individual dart files instead of
# passing the entire project directory, because the dartanalyzer CLI does not
# respect the "excludes" option.
# See: https://github.com/dart-lang/sdk/issues/26212
.PHONY: dart-lint
dart-lint: dart-base
	@for pkg in $(DART_PACKAGES); do \
		echo "** Running the dartanalyzer in '$${pkg}' ..."; \
		pushd $${pkg} > /dev/null; \
		files=$$(find . -name "*.dart" ! -wholename "*.mojom.dart"); \
		if [ "$${files}" ]; then \
			dartanalyzer --lints --fatal-lints --fatal-warnings \
				$$files || exit 1; \
		else \
			echo "No dart source files found to analyze."; \
		fi; \
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
## Mojom binding generation related targets
.PHONY: mojom-gen
mojom-gen: $(MOJOM_DART_SYMLINKS)
	@for symlink in $(MOJOM_DART_SYMLINKS); do \
		if [ -f "$${symlink}" ]; then \
			continue; \
		fi; \
		if [[ $${symlink} == ./* ]]; then \
			symlink=$${symlink:2}; \
		fi; \
		filename=$$(basename $${symlink}); \
		srcname=$${filename%.*}; \
		output=$(GEN_DIR)/modules/$$(dirname $$(dirname $${symlink}))/$${filename}; \
		if [ ! -f "$${output}" ]; then \
			echo "Could not find the dart binding generated from '$${srcname}' file."; \
			echo "Make sure that you included '$${srcname}' in the relevant 'BUILD.gn' file."; \
			exit 1; \
		fi; \
		mkdir -p $$(dirname $${symlink}); \
		ln -s $${output} $${symlink}; \
	done

.PHONY: mojom-clean
mojom-clean:
	@rm -rf $(GEN_DIR)/modules $(MOJOM_DART_SYMLINKS)

$(MOJOM_DART_SYMLINKS): $(MOJOM_DART_OUTPUTS)
	@true

# Generate the mojom bindings from the mojom files.
#
# NOTE(youngseokyoon): We don't need the .h header files, but this is added here
# on purpose. By having multiple pattern rule targets on the same line, make
# tool understands that these multiple files are all generated by running the
# commands once, rather than having to run this recipe for each target file.
$(GEN_DIR)/modules/%.dart $(GEN_DIR)/modules/%.h: % $(GN_FILES) $(OUT_DIR)/sysroot
ifeq ($(GOMA_INSTALLED), yes)
	@~/goma/goma_ctl.py ensure_start
else
	$(warning [WARNING] Goma not installed. Install Goma to get faster distributed builds.)
endif
	@cd .. && packages/gn/gen.py $(GEN_FLAGS) -m "sysui"
	@cd .. && buildtools/ninja $(NINJA_FLAGS) -C out/debug-x86-64

# Build sysroot if needed.
$(OUT_DIR)/sysroot: $(MAGENTA_BUILD_DIR)/sysroot
	@cd .. && scripts/build-sysroot.sh -c -t x86_64

# Build magenta if needed.
$(MAGENTA_BUILD_DIR)/sysroot:
	@cd ../magenta && scripts/build-magenta-x86-64
