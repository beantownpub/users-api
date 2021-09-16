.PHONY: all test clean

repository ?= jalgraves
env ?= dev
pg_host ?= $(shell docker inspect pg | jq .[0].NetworkSettings.Networks.bridge.IPAddress || echo "no-container")
tag ?= $(shell yq eval '.info.version' swagger.yaml)
name ?= users_api

ifeq ($(env),dev)
	pg_host = ${POSTGRES_IP}
	pg_port = 32432
else
	pg_host = postgres.default.svc.cluster.local
	pg_port = 5432
endif

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

start: stop
		@echo "\033[1;32m. . . Starting Users API container . . .\033[1;37m\n"
		docker run \
			--name $(name) \
			--restart always \
			-p "5004:5004" \
			-e DB_NAME=${FOOD_DB} \
			-e DB_USER=${DB_USER} \
			-e DB_PWD=${DB_PWD} \
			-e DB_HOST=$(pg_host) \
			-e API_USER_PWD=${API_PW} \
			-e API_USER=${API_USER} \
			$(name)

stop:
		docker rm -f $(name) || true

kill_pod:
		kubectl get pods |  grep users-api | cut -f 1 -d " " | xargs kubectl delete pod

redis:
		docker run -d --name red -p "6379:6379" --restart always redis

clean:
		rm -rf api/__pycache__ || true
		rm .DS_Store || true
		rm api/*.pyc
