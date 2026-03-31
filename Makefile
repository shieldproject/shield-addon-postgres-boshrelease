SHELL := /bin/bash

# PostgreSQL upstream source base URL
PG_MIRROR := https://ftp.postgresql.org/pub/source

# Versions derived from config/blobs.yml
PG_VERSIONS := 9.6.24 10.23 11.22 13.23 14.22 15.17 16.13 17.9 18.3

# Generate blob paths
PG_BLOBS := $(foreach v,$(PG_VERSIONS),blobs/postgres/postgresql-$(v).tar.bz2)

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show available targets
	@printf "\n\033[1mSHIELD PostgreSQL Addon - Blob Management\033[0m\n\n"
	@printf "\033[36m%-24s\033[0m %s\n" "Target" "Description"
	@printf "\033[36m%-24s\033[0m %s\n" "------" "-----------"
	@grep -E '^[a-zA-Z0-9._-]+:.*##' $(MAKEFILE_LIST) \
		| sed 's/:.*## /\t/' \
		| awk -F'\t' '{ printf "\033[33m%-24s\033[0m %s\n", $$1, $$2 }'
	@echo

.PHONY: blobs
blobs: $(PG_BLOBS) ## Download all PostgreSQL source blobs

blobs/postgres/postgresql-%.tar.bz2:
	@mkdir -p blobs/postgres
	@version=$*; \
	url="$(PG_MIRROR)/v$${version}/postgresql-$${version}.tar.bz2"; \
	printf "\033[36m>>>\033[0m Downloading PostgreSQL \033[33m%s\033[0m ...\n" "$${version}"; \
	curl -fSL -o "$@" "$${url}" \
		|| { rm -f "$@"; printf "\033[31m!!! Failed to download %s\033[0m\n" "$${url}"; exit 1; }
	@printf "\033[32m    ok\033[0m %s\n" "$@"

.PHONY: verify
verify: ## Verify blob checksums against config/blobs.yml
	@printf "\n\033[1mVerifying blob checksums\033[0m\n\n"
	@ok=0; fail=0; \
	for blob in $(PG_BLOBS); do \
		key=$$(echo "$$blob" | sed 's|^blobs/||'); \
		if [ ! -f "$$blob" ]; then \
			printf "\033[33m  SKIP\033[0m %s (not downloaded)\n" "$$key"; \
			continue; \
		fi; \
		expected=$$(awk "/^$$(echo $$key | sed 's|/|\\/|g'):/,/sha:/" config/blobs.yml \
			| grep 'sha:' | head -1 | sed 's/.*sha256://'); \
		if [ -z "$$expected" ]; then \
			printf "\033[33m  SKIP\033[0m %s (no sha256 in blobs.yml)\n" "$$key"; \
			continue; \
		fi; \
		actual=$$(shasum -a 256 "$$blob" | awk '{print $$1}'); \
		if [ "$$actual" = "$$expected" ]; then \
			printf "\033[32m    ok\033[0m %s\n" "$$key"; \
			ok=$$((ok + 1)); \
		else \
			printf "\033[31m  FAIL\033[0m %s\n" "$$key"; \
			printf "       expected: %s\n" "$$expected"; \
			printf "         actual: %s\n" "$$actual"; \
			fail=$$((fail + 1)); \
		fi; \
	done; \
	echo; \
	printf "\033[1m%d passed, %d failed\033[0m\n\n" "$$ok" "$$fail"; \
	[ "$$fail" -eq 0 ]

.PHONY: clean
clean: ## Remove all downloaded blobs
	rm -rf blobs/postgres
	@printf "\033[32mCleaned\033[0m blobs/postgres\n"

.PHONY: list
list: ## List blob versions and download status
	@printf "\n\033[1mPostgreSQL Blobs\033[0m\n\n"
	@printf "\033[36m%-12s %-40s %s\033[0m\n" "Version" "Blob" "Status"
	@printf "\033[36m%-12s %-40s %s\033[0m\n" "-------" "----" "------"
	@for blob in $(PG_BLOBS); do \
		version=$$(echo "$$blob" | sed 's|.*postgresql-\(.*\)\.tar\.bz2|\1|'); \
		if [ -f "$$blob" ]; then \
			printf "\033[33m%-12s\033[0m %-40s \033[32m%s\033[0m\n" "$$version" "$$blob" "downloaded"; \
		else \
			printf "\033[33m%-12s\033[0m %-40s \033[31m%s\033[0m\n" "$$version" "$$blob" "missing"; \
		fi; \
	done
	@echo
