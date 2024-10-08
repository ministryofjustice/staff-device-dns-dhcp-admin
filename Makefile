#!make
.DEFAULT_GOAL := help
-include .env
export

ifndef ENV
ENV=development
REGISTRY_URL=683290208331.dkr.ecr.eu-west-2.amazonaws.com
endif

UID=$(shell id -u)
DOCKER_COMPOSE = env ENV=${ENV} UID=$(UID) docker-compose -f docker-compose.yml
BUNDLE_FLAGS=

DOCKER_BUILD_CMD = BUNDLE_INSTALL_FLAGS="$(BUNDLE_FLAGS)" $(DOCKER_COMPOSE) build

.PHONY: authenticate_docker
authenticate-docker: ## Authenticate docker script
	./scripts/authenticate_docker.sh

.PHONY: build
build: ## docker build image
	docker build --platform linux/amd64 -t admin . --build-arg RACK_ENV --build-arg DB_HOST --build-arg DB_USER --build-arg DB_PASS --build-arg SECRET_KEY_BASE --build-arg DB_NAME --build-arg BUNDLE_WITHOUT

.PHONY: build-dev
build-dev: ## build-dev image
	$(DOCKER_COMPOSE) build --build-arg BUILD_DEV="true"

.PHONY: shell-dev
shell-dev: ## Run application and start shell
	$(DOCKER_COMPOSE) run --rm app sh

.PHONY: start-db
start-db: ## start database
	$(DOCKER_COMPOSE) up -d admin-db
	ENV=${ENV} ./scripts/wait_for_db.sh

.PHONY: db-setup
db-setup: ## setup database
	$(MAKE) start-db
	$(DOCKER_COMPOSE) run --rm app ./bin/rails db:drop db:create db:schema:load

.PHONY: serve
serve: ## Start application
	$(MAKE) stop
	$(MAKE) start-db
	$(DOCKER_COMPOSE) up app

.PHONY: phpmyadmin
phpmyadmin: ## Start phpmyadmin
	$(DOCKER_COMPOSE) up phpmyadmin

# TODO - this is potentially not needed, but we should check by running tests before removing
# run: serve

.PHONY: test
test: ## build and run tests
	export ENV=test
	$(DOCKER_COMPOSE) run -e COVERAGE=true --rm app bundle exec rake

.PHONY: shell
shell: ## build and run tests in shell
	$(DOCKER_COMPOSE) run --rm app sh

.PHONY: shell-test
shell-test: ## build and run tests in shell with test variable
	export ENV=test
	$(DOCKER_COMPOSE) run --rm app sh

.PHONY: stop
stop: ## docker compose down
	$(DOCKER_COMPOSE) down

.PHONY: migrate
migrate: ## run migrate script
	./scripts/migrate.sh

.PHONY: seed
seed: ## run seed script
	./scripts/seed.sh

.PHONY: migrate-dev
migrate-dev: ## run rails migrate dev
	$(DOCKER_COMPOSE) run --rm app bundle exec rake db:migrate

.PHONY: bootstrap
bootstrap: ## run bootstrap script
	./scripts/bootstrap.sh

.PHONY: deploy
deploy: ## run deploy script
	./scripts/deploy.sh

.PHONY: push
push: ## push image to ECR
	aws ecr get-login-password | docker login --username AWS --password-stdin ${REGISTRY_URL}
	docker tag admin:latest ${REGISTRY_URL}/staff-device-dhcp-admin:${ENV}-latest
	docker push ${REGISTRY_URL}/staff-device-dhcp-admin:${ENV}-latest

.PHONY: publish
publish: ## run build and push targets
	$(MAKE) build
	$(MAKE) push

.PHONY: promote
promote: ## Re-tag image to promote to new environment
	aws ecr get-login-password | docker login --username AWS --password-stdin ${REGISTRY_URL}
	docker tag ${IMAGE_TAG_TO_PROMOTE} ${REGISTRY_URL}/staff-device-dhcp-admin:${ENV}-latest
	docker push ${REGISTRY_URL}/staff-device-dhcp-admin:${ENV}-latest

.PHONY: lint
lint: ## lint
	$(DOCKER_COMPOSE) run --rm app bundle exec rake standard:fix

.PHONY: implode
implode: ## remove docker container
	$(DOCKER_COMPOSE) rm

help:
	@grep -h -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
