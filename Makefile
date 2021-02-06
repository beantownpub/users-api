.PHONY: all test clean

name ?= auth_api
pg_host ?= $(shell docker inspect pg | jq .[0].NetworkSettings.Networks.bridge.IPAddress || echo "no-container")

build:
		@echo "\033[1;32m. . . Building Auth API image . . .\033[1;37m\n"
		docker build -t $(name) .

build_no_cache:
		docker build -t $(name) . --no-cache=true

publish: build
		docker tag $(name) jalgraves/$(name)
		docker push jalgraves/$(name)

start:
		@echo "\033[1;32m. . . Starting Auth API container . . .\033[1;37m\n"
		docker run \
			--name $(name) \
			--restart always \
			-p "5045:5045" \
			-e AUTH_DB=${AUTH_DB} \
			-e AUTH_DB_USER=${AUTH_DB_USER} \
			-e AUTH_DB_PW=${AUTH_DB_PW} \
			-e AUTH_DB_HOST=$(pg_host) \
			-e API_USER_PW=${API_PW} \
			$(name)

stop:
		docker rm -f $(name) || true


compile:
		pip-compile requirements.ini

clean:
		rm -rf api/__pycache__ || true
		rm .DS_Store || true
		rm api/*.pyc