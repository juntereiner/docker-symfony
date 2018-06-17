
DOCKER_COMPOSE  = docker-compose

EXEC_PHP        = $(DOCKER_COMPOSE) exec engine /entrypoint
EXEC_PHP_T      = $(DOCKER_COMPOSE) exec -T engine /entrypoint

SYMFONY         = $(EXEC_PHP) bin/console
COMPOSER        = $(EXEC_PHP) composer

ARTEFACTS       = artefacts

##
## Project
## -------
##

build:
	$(DOCKER_COMPOSE) build

kill:
	$(DOCKER_COMPOSE) kill
	$(DOCKER_COMPOSE) down --volumes --remove-orphans

install: ## Install and start the project
install: .env build start init-jwt presets

reset: ## Stop and start a fresh install of the project
reset: kill install

start: ## Start all docker containers
	$(DOCKER_COMPOSE) up -d --remove-orphans

stop: ## Stop all docker containers
	$(DOCKER_COMPOSE) stop

enter-docker: ## Enter in the engine container
	$(EXEC_PHP) zsh

in:
	$(eval DOCKER_COMPOSE := \#)
	$(eval EXEC_PHP := )

.PHONY: build kill install reset start stop in

##
## Utils
## -------
##

fileperm: ## Create ACL on folders var, public/upload
	sudo setfacl -R -m u:www-data:rwX -m u:`whoami`:rwX var public
	sudo setfacl -dR -m u:www-data:rwX -m u:`whoami`:rwX var public

cache-clear:
	$(SYMFONY) cache:clear

diff: ## Generate a new doctrine migration
	$(SYMFONY) doctrine:migrations:diff

migration: ## Apply migrations
	$(SYMFONY) doctrine:migrations:migrate

.PHONY: fileperm diff migration cache-clear

##
## Tests
## -----
##

prepare-test:
	rm -rf var/cache/test
	$(SYMFONY) --env=test doctrine:database:drop --if-exists --no-interaction --force -q #--quiet
	$(SYMFONY) --env=test doctrine:database:create --no-interaction -q
	$(SYMFONY) --env=test doctrine:migrations:migrate --no-interaction -q
	$(SYMFONY) --env=test hautelook:fixtures:load --no-interaction -q

tests: ## Run all tests
tests: prepare-test
	$(EXEC_PHP) bin/codecept run

tests-coverage: ## Run all tests for coverage with phpdbg
tests-coverage: prepare-test
	$(EXEC_PHP) phpdbg -qrr bin/codecept run --coverage-html

.PHONY: test tests


# rules based on files
composer.lock: composer.json
	$(COMPOSER) update --lock --no-scripts --no-interaction

vendor: composer.lock
	$(COMPOSER) install

.env: .env.dist
	@if [ -f .env ]; \
	then\
		echo '\033[1;41m/!\ The .env.dist file has changed. Please check your .env file (this message will not be displayed again).\033[0m';\
		touch .env;\
		exit 1;\
	else\
		echo cp .env.dist .env;\
		cp .env.dist .env;\
	fi

##
## Quality assurance
## -----------------
##

phpmetrics: ## PhpMetrics (http://www.phpmetrics.org)
	$(EXEC_PHP) bin/phpmetrics --report-html=$(ARTEFACTS)/phpmetrics src/ --exclude=src/Migrations/

phpmd: ## PHP Mess Detector (https://phpmd.org)
	$(EXEC_PHP) bin/phpmd src/ html phpmd.xml --reportfile $(ARTEFACTS)/phpmd.html

phpstan:
	$(EXEC_PHP_T) bin/phpstan analyse -l 5 -c phpstan.neon src > $(ARTEFACTS)/phpstan-report.txt

phpcsfixer: ## apply php-cs-fixer fixes (http://cs.sensiolabs.org)
	$(EXEC_PHP) bin/php-cs-fixer --allow-risky=yes fix

.PHONY: phpmetrics phpmd phpcsfixer


.DEFAULT_GOAL := help
help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
.PHONY: help
