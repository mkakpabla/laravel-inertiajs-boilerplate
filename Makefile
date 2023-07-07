# .RECIPEPREFIX = "    "
# Change tabs to space in makefile

# Load .env variable (the prod is added also if there is any)
ifneq (,$(wildcard ./.env))
    include .env
    export
endif
ifneq (,$(wildcard ./.env.prod))
    include .env
    export
endif

# connect to the back container
.PHONY: bash
bash: ;\
    docker compose exec back bash;

# Launch migration
.PHONY: migrate
migrate: ;\
    docker compose exec back php artisan migrate

.PHONY: rollback
rollback: ;\
    docker compose exec back php artisan migrate:rollback

.PHONY: seed
seed: ;\
    docker compose exec back php artisan db:seed

.PHONY: tinker
tinker: ;\
    docker compose exec back php artisan tinker

# See logs of back
.PHONY: backlogs
backlogs: ;\
    docker-compose logs back -f

# Init dev env
.PHONY: init-dev
init-dev: ;\
    cp -n docker-compose.override.yml.template docker-compose.override.yml; \
    cp -n .env.dist .env;

#
# Theses are usefull when you use docker
#

# down docker compose
down: ;\
    docker compose down
# up docker compose
up: ;\
    DOCKER_BUILDKIT=1 docker compose up -d

# stronger down (remove volume / image / orphans)
.PHONY: fdown
fdown: ;\
   docker compose down -v --remove-orphans

# stronger up (recreate all container and rebuild the image)
fup: ;\
    DOCKER_BUILDKIT=1 docker compose up -d --force-recreate --build

# Soft Restart
.PHONY: restart
restart: down up

# Hard restart
.PHONY: frestart
frestart: fdown fup

#
# Theses are static analyses + tests
#

.PHONY: cs-fix
cs-fix: ;\
	docker compose exec back composer cs-fix

.PHONY: cs-check
cs-check: ;\
	docker compose exec back composer cs-check

.PHONY: phpstan
phpstan: ;\
	docker compose exec back composer phpstan

# Run all CI tools
.PHONY: ci
ci: cs-fix phpstan

.PHONY: dump
dump: ;\
    docker compose exec mysql mysqldump -u ${DATABASE_USERNAME} -p${DATABASE_PASSWORD} ${DATABASE_NAME} > apps/back/dump/dump.sql


.PHONY: dev
dev: ;\
    docker compose exec back yarn dev