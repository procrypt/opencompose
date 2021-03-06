#!/usr/bin/make -f
.PHONY: all
all: build

SHELL :=/bin/bash

GOFMT :=gofmt -s
GOIMPORTS :=goimports -e

GO_FILES :=$(shell find . -name '*.go' -not -path './vendor/*' -print)
GO_PACKAGES = $(shell glide novendor)


.PHONY: build
build:
	go build

.PHONY: install
install:
	go install

.PHONY: test
test:
	go test $(GO_PACKAGES)

.PHONY: checks
checks: check-gofmt check-goimports check-govet

.PHONY: check-gofmt
check-gofmt:
	@export files && files="$$($(GOFMT) -l $(GO_FILES))" && \
	if [ -n "$${files}" ]; then printf "ERROR: These files are not formated by $(GOFMT):\n"; printf "%s\n" $${files[@]}; exit 1; fi

.PHONY: check-goimports
check-goimports:
	@export files && files="$$($(GOIMPORTS) -l $(GO_FILES))" && \
	if [ -n "$${files}" ]; then printf "ERROR: These files are not formated by $(GOIMPORTS):\n"; printf "%s\n" $${files[@]}; exit 1; fi

.PHONY: check-govet
check-govet:
	go vet $(GO_PACKAGES)

.PHONY: check-strip-vendor
check-strip-vendor:
	@export vendors && vendors=$$(find ./vendor/ -mindepth 1 -type d -name 'vendor') && \
	if [ -n "$${vendors}" ]; then printf "ERROR: There are nested vendor directories: \n"; printf "%s\n" $${vendors[@]}; exit 1; fi
	@export files && files=$$($(do-strip-vendor) --dryrun) && \
	if [ -n "$${files}" ]; then printf "ERROR: There are unused files in ./vendor/\nRun 'make strip-vendor' to fix it.\n"; exit 1; fi

.PHONY: format
format: format-gofmt format-goimports

.PHONY: format-gofmt
format-gofmt:
	$(GOFMT) -w $(GO_FILES)

.PHONY: format-goimports
format-goimports:
	$(GOIMPORTS) -w $(GO_FILES)

do-strip-vendor :=glide-vc --only-code --no-tests --no-test-imports --no-legal-files

.PHONY: recreate-vendor
recreate-vendor:
	glide install --strip-vendor
	$(do-strip-vendor)

.PHONY: update-vendor
update-vendor:
	glide update --strip-vendor
	$(do-strip-vendor)

.PHONY: strip-vendor
strip-vendor:
	$(do-strip-vendor)
