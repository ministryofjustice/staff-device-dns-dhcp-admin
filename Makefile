DOCKER_COMPOSE = docker-compose -f docker-compose.yml
BUNDLE_FLAGS=

ifdef DEPLOYMENT
  BUNDLE_FLAGS = --without test development
endif

DOCKER_BUILD_CMD = BUNDLE_INSTALL_FLAGS="$(BUNDLE_FLAGS)" $(DOCKER_COMPOSE) build

build:
	docker build -t docker_admin .

prebuild:
	$(DOCKER_COMPOSE) build
	$(DOCKER_COMPOSE) up --no-start

serve: stop build
	$(DOCKER_COMPOSE) up -d db
	./mysql/bin/wait_for_mysql
	$(DOCKER_COMPOSE) run --rm app ./bin/rails db:create db:migrate db:seed
	$(DOCKER_COMPOSE) up --build app

test: stop build
	$(DOCKER_COMPOSE) up -d db
	./mysql/bin/wait_for_mysql
	$(DOCKER_COMPOSE) run -e RACK_ENV=test --rm app ./bin/rails db:create db:schema:load db:migrate
	$(DOCKER_COMPOSE) run --rm app bundle exec rspec

shell: serve
	$(DOCKER_COMPOSE) exec app bash

stop:
	$(DOCKER_COMPOSE) down -v

deploy: build
	echo ${SECRET_KEY_BASE}
	echo ${REGISTRY_URL}
	aws ecr get-login-password | docker login --username AWS --password-stdin ${REGISTRY_URL}
	docker tag docker_admin:latest ${REGISTRY_URL}/staff-device-${ENV}-dns-dhcp-admin:latest
	docker push ${REGISTRY_URL}/staff-device-${ENV}-dns-dhcp-admin_app:latest

.PHONY: build serve shell stop test deploy
