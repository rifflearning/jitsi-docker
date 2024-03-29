# The order to combine the compose/stack config files for spinning up
# the riff services using either docker-compose or docker stack
# for development, production or deployment in a docker swarm
# production used to have additional config but now it's just base.
CONF_BASE   := docker-compose.yml
CONF_DEV    := $(CONF_BASE) docker-compose.dev.yml
CONF_PROD   := $(CONF_BASE)
CONF_DEPLOY := $(CONF_PROD) docker-stack.yml

COMPOSE_CONF_DEV := $(patsubst %,-f %,$(CONF_DEV))
COMPOSE_CONF_PROD := $(patsubst %,-f %,$(CONF_PROD))
STACK_CONF_DEPLOY := $(patsubst %,-c %,$(CONF_DEPLOY))

.DEFAULT_GOAL := help
.DELETE_ON_ERROR :
.PHONY : help up down stop logs up-dev

up : up-dev ## run docker-compose up (w/ dev config)

up-dev :
	docker-compose $(COMPOSE_CONF_DEV) up $(MAKE_UP_OPTS) $(OPTS)

down : ## run docker-compose down
	docker-compose down

stop : ## run docker-compose stop
	docker-compose stop

logs : ## run docker-compose logs
	docker-compose logs $(OPTS) $(SERVICE_NAME)

deploy-stack : ## deploy the pfm-stk stack defined by compose/stack config (just riffdata)
	docker stack deploy $(STACK_CONF_DEPLOY) --with-registry-auth pfm-stk

remove-stack : ## remove the pfm-stk stack
	docker stack remove pfm-stk

build-dev : ## (re)build the dev images pulling the latest base images
	docker-compose $(COMPOSE_CONF_DEV) build --pull $(OPTS) $(SERVICE_NAME)

dev-server : SERVICE_NAME = pfm-riffdata ## start a dev container for the riff-server
dev-server : _start-dev

.PHONY : _start-dev
_start-dev :
	$(call ndef,SERVICE_NAME)
	-docker-compose $(COMPOSE_CONF_DEV) run --service-ports $(OPTS) $(SERVICE_NAME) bash
	-docker-compose rm --force -v
	-docker-compose stop

# Add all constraint labels to the single docker node running in swarm mode on a development machine
dev-swarm-labels : ## add all constraint labels to single swarm node
	docker node update --label-add web=true \
                       --label-add mongo=true \
                       $(shell docker node ls --format="{{.ID}}")

# Help documentation à la https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
# if you want the help sorted rather than in the order of occurrence, pipe the grep to sort and pipe that to awk
help : ## this help documentation (extracted from comments on the targets)
	@echo ""                                            ; \
	echo "Useful targets in this riff-docker Makefile:" ; \
	(grep -E '^[a-zA-Z_-]+ ?:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = " ?:.*?## "}; {printf "\033[36m%-20s\033[0m : %s\n", $$1, $$2}') ; \
	echo ""

