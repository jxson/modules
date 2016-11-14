MAKEFLAGS += --warn-undefined-variables --no-print-directory
SHELL := /bin/bash

.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

DIRNAME := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
FUCHSIA_ROOT := $(realpath $(DIRNAME)/../../../)
FLUTTER_DIR := $(FUCHSIA_ROOT)/lib/flutter
FLUTTER_BIN := $(FLUTTER_DIR)/bin
DART_BIN := $(FLUTTER_BIN)/cache/dart-sdk/bin
PATH := $(FLUTTER_BIN):$(DART_BIN):$(PATH)

.PHONY: all
all:
	@make -C ../ all

.PHONY: auth
auth: all
	@cd tools; \
	pub run bin/oauth.dart
