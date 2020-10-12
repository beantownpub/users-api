.PHONY: all test clean

build:
		@echo "\033[1;32m. . . Building Menu API image . . .\033[1;37m\n"
		docker build -t menu_api .

build_no_cache:
		docker build -t menu_api . --no-cache=true

publish: build
		docker tag menu_api jalgraves/menu_api
		docker push jalgraves/menu_api

start:
		@echo "\033[1;32m. . . Starting Menu API container . . .\033[1;37m\n"
		docker run \
			--name menu_api \
			--restart always \
			-p "5004:5004" \
			-e MONGO_HOST=${MONGO_REMOTE} \
			-e MONGO_PW=${MENU_API_MONGO_PW} \
			-e MONGO_USER=${MENU_API_MONGO_USER} \
			-e MONGO_DB=${MENU_API_DB} \
			menu_api

stop:
		docker rm -f menu_api || true

redis:
		docker run -d --name red -p "6379:6379" --restart always redis

mongo:
		@echo "\033[1;32m. . . Starting MongoDB container . . .\n"
		mkdir -p ${PWD}/data || true
		docker run \
			-d \
			-p 27017-27019:27017-27019 \
			-e MONGO_INITDB_ROOT_PASSWORD=${MENU_API_MONGO_PW} \
			-e MONGO_INITDB_ROOT_USERNAME=${MENU_API_MONGO_USER} \
			-v ${PWD}/data:/data/db \
			--name mongodb \
			--restart always \
			mongo:4.0.13-xenial

mongo_no_auth:
		@echo "\033[1;32m. . . Starting MongoDB container . . .\033[1;37m\n"
		mkdir -p ${PWD}/data || true
		docker run \
			-d \
			-p 27017-27019:27017-27019 \
			-v ${PWD}/data:/data/db \
			--name mongodb \
			--restart always \
			mongo:4.0.13-xenial

clean:
		rm -rf api/__pycache__ || true
		rm .DS_Store || true
		rm api/*.pyc