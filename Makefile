.PHONY: all test clean

repository ?= jalgraves
tag ?= $(shell yq eval '.info.version' swagger.yaml)
name ?= users_api

compile:
		pip-compile requirements.in

build:
		@echo "\033[1;32m. . . Building Users API image . . .\033[1;37m\n"
		docker build -t $(name):$(tag) .

build_no_cache:
		docker build -t $(name) . --no-cache=true

publish: build
		docker tag $(name):$(tag) $(repository)/$(name):$(tag)
		docker push $(repository)/$(name):$(tag)

latest: build
		docker tag $(name):$(tag) $(repository)/$(name):latest
		docker push $(repository)/$(name):latest

clean:
		rm -rf api/__pycache__ || true
		rm .DS_Store || true
		rm api/*.pyc
