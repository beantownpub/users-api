database_enabled ?= false
port ?= ${USERS_API_PORT}
log_level ?= DEBUG
db_release_name ?= psql
db_pvc_enabled ?= false
db_tag ?= latest

helm/package:
		helm package .

helm/clean:
		rm *.tgz || true

context:
	kubectl config use-context $(context)

## Helm dependencies update
helm/deps/update:
	cd helm/users-api && \
		helm dependencies update

## Create chart schema
helm/schema_create:
	cd helm/users-api && helm schema-gen values.yaml > values.schema.json

## Create the credentials that are consumed by the users-api
helm/creds/app:
	@echo "\033[1;32m. . . Installing creds $(env) secret . . .\033[1;37m\n"
	kubectl config use-context $(context) && \
	kubectl create secret generic db-creds \
		--namespace $(namespace) \
		--from-literal=api_user="${API_USERNAME}" \
		--from-literal=api_pass="${API_PASSWORD}" \
		--from-literal=db_host="${DB_HOST}" \
		--from-literal=db_pass="${DB_PASS}" \
		--from-literal=db_port="${DB_PORT}" \
		--from-literal=db_user="${DB_USER}" \
		--from-literal=db_name="${DB_NAME}" \
		--from-literal=default_admin_email="${DEFAULT_ADMIN_EMAIL}" \
		--from-literal=default_admin_user="${DEFAULT_ADMIN_USER}" \
		--from-literal=default_admin_pass="${DEFAULT_ADMIN_PASS}"


## Start port forwarding
helm/port_forward:
	kubectl port-forward --namespace $(namespace) svc/$(name) $(port):$(port)

## Stop port forwarding
helm/stop_pf:
	./scripts/stop_port_forward.sh $(port)


## Create the credentials that are consumed by the psql database
helm/creds/db:
	@echo "\033[1;32m. . . Installing database creds $(env) secret . . .\033[1;37m\n"
	kubectl config use-context $(context) && \
	kubectl create secret generic db-creds \
		--namespace database \
		--from-literal=db_admin_pass="${DB_ADMIN_PASS}" \
		--from-literal=db_admin_user="${DB_ADMIN_USER}" \
		--from-literal=db_pass="${DB_PASS}" \
		--from-literal=db_user="${DB_USER}"


## Install users-api in K8s cluster
helm/install:
	cd helm/users-api && \
	kubectl config use-context $(context) && \
	helm upgrade --install $(name) . \
		--namespace $(namespace) \
		--set global.env=$(env) \
		--set image.name=$(image_name) \
		--set image.tag=$(image_tag) \
		--set logLevel=$(log_level) \
		--set database.enabled=$(database_enabled) \
		--set psql.fullnameOverride="psql" \
		--debug

## Uninstall users-api frontend from K8s cluster
helm/uninstall:
	kubectl config use-context $(context) && \
		helm uninstall $(name) -n $(namespace)

## Uninstall and reinstall users-api frontend from K8s cluster
helm/reinstall: helm/uninstall helm/stop_pf helm/install

helm/template:
	cd helm/users-api && \
	kubectl config use-context $(context) && \
	helm template $(name) . \
		--namespace $(namespace) \
		--set global.env=$(env) \
		--set image.name=$(image_name) \
		--set image.tag=$(image_tag) \
		--set logLevel=$(log_level) \
		--debug

## Install psql database in cluster
helm/db/install:
	kubectl config use-context $(context) && \
	helm upgrade --install $(db_release_name) beantown/psql \
		--namespace ${DB_NAMESPACE} \
		--set image.tag=$(db_tag) \
		--set db_admin_pass=${DB_ADMIN_PASS} \
		--set db_admin_user=${DB_ADMIN_USER} \
		--set db_pass=${DB_PASS} \
		--set db_user=${DB_USER} \
		--set contactDbName=${CONTACT_DB_NAME} \
		--set contentDbName=${CONTENT_DB_NAME} \
		--set menuDbName=${MENU_DB_NAME} \
		--set merchDbName=${MERCH_DB_NAME} \
		--set usersDbName=${USERS_DB_NAME} \
		--set pvc.enabled=$(db_pvc_enabled) \
		--debug


port_forward:
		kubectl port-forward --namespace $(namespace) svc/$(name) $(port):$(port)

stop_pf:
		../scripts/stop_port_forward.sh $(namespace) $(name)

logs:
		../scripts/get_pod_logs.sh $(namespace) $(name)

describe:
		../scripts/describe_pod.sh $(namespace) $(name)

kill_pod:
		../scripts/kill_pod.sh $(namespace) $(name)

secret:
	kubectl create secret generic users-api-creds \
		--namespace $(namespace) \
		--from-literal=default_admin_email="${DEFAULT_ADMIN_EMAIL}" \
		--from-literal=default_admin_user="${DEFAULT_ADMIN_USER}" \
		--from-literal=default_admin_pass="${DEFAULT_ADMIN_PASS}" \
		--from-literal=db_name="${USERS_DB_NAME}"
