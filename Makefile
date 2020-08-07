DOCKER_COMPOSE = docker-compose -f docker-compose.yml
BUNDLE_FLAGS=

ifdef DEPLOYMENT
  BUNDLE_FLAGS = --without test development
endif

DOCKER_BUILD_CMD = BUNDLE_INSTALL_FLAGS="$(BUNDLE_FLAGS)" $(DOCKER_COMPOSE) build

build:
	docker build -t docker_admin . --build-arg RACK_ENV --build-arg DB_HOST --build-arg DB_USER --build-arg DB_PASS --build-arg SECRET_KEY_BASE 

serve: stop build
	$(DOCKER_COMPOSE) up -d db
	./mysql/bin/wait_for_mysql
	$(DOCKER_COMPOSE) run --rm app ./bin/rails db:create db:migrate db:seed
	$(DOCKER_COMPOSE) up --build app

stop:
	$(DOCKER_COMPOSE) down -v

deploy: build
	echo ${SECRET_KEY_BASE}
	echo ${REGISTRY_URL}
	aws ecr get-login-password | docker login --username AWS --password-stdin ${REGISTRY_URL}
	docker tag docker_admin:latest ${REGISTRY_URL}/staff-device-${ENV}-dns-dhcp-admin:latest
	docker push ${REGISTRY_URL}/staff-device-${ENV}-dns-dhcp-admin:latest

.PHONY: build serve stop test deploy
