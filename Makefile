-include \
	helm/users-api/Makefile

.PHONY: all test clean

export MAKE_PATH ?= $(shell pwd)
export SELF ?= $(MAKE)

MAKE_FILES = \
	${MAKE_PATH}/Makefile \
	${MAKE_PATH}/helm/users-api/Makefile

repository ?= jalgraves
version ?= $(shell yq eval '.info.version' swagger.yaml)
name ?= users-api
image_name ?= $(name)
git_hash = $(shell git rev-parse --short HEAD)

ifeq ($(env),dev)
	image_tag = $(version)-$(git_hash)
	context = ${DEV_CONTEXT}
	namespace = ${DEV_NAMESPACE}
else ifeq ($(env),prod)
	image_tag = $(version)
	context = ${PROD_CONTEXT}
	namespace = ${PROD_NAMESPACE}
endif

compile:
	pip-compile -r -U requirements.in

build:
	@echo "\033[1;32m. . . Building Users API image . . .\033[1;37m\n"
	docker build \
		-t $(image_name):$(image_tag) \
		--platform linux/x86_64 .

build_no_cache:
	docker build -t $(image_name):$(image_tag) . --no-cache=true

## Build users-api image and push to dockerhub
publish: build
	docker tag $(image_name):$(image_tag) $(repository)/$(image_name):$(image_tag)
	docker push $(repository)/$(image_name):$(image_tag)

latest: build
	docker tag $(image_name):$(image_tag) $(repository)/$(image_name):latest
	docker push $(repository)/$(image_name):latest

clean:
	rm -rf api/__pycache__ || true
	rm .DS_Store || true
	rm api/*.pyc

## Show available commands
help:
	@printf "Available targets:\n\n"
	@$(SELF) -s help/generate | grep -E "\w($(HELP_FILTER))"
	@printf "\n\n"

help/generate:
	@awk '/^[a-zA-Z\_0-9%:\\\/-]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = $$1; \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			gsub("\\\\", "", helpCommand); \
			gsub(":+$$", "", helpCommand); \
			printf "  \x1b[32;01m%-35s\x1b[0m %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKE_FILES) | sort -u
