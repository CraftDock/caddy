## Name of the image
DOCKER_IMAGE=dsuite/caddy

## Current directory
DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

## Define the latest version
version = latest

## Config
.DEFAULT_GOAL := build
.PHONY: *


build:
	@docker build  \
		--file $(DIR)/Dockerfile \
		--tag $(DOCKER_IMAGE):$(version) \
		$(DIR)

test:
	@docker run --rm -t \
		-v $(DIR)/tests:/goss \
		-v /tmp:/tmp \
		-v /var/run/docker.sock:/var/run/docker.sock \
		dsuite/goss:latest \
		dgoss run -e CADDY=$(version) --entrypoint=/goss/entrypoint.sh $(DOCKER_IMAGE):$(version)

push:
	@docker push $(DOCKER_IMAGE):$(version)


shell:
	@docker run -it --rm \
		-e DEBUG_LEVEL=DEBUG \
		$(DOCKER_IMAGE):$(version) \
		bash

remove:
	@if [ $(shell docker images -f "dangling=true" -q | wc -l) -gt 0 ]; then \
		docker rmi -f $(shell docker images -f "dangling=true" -q); \
	fi
	@docker images | grep $(DOCKER_IMAGE) | tr -s ' ' | cut -d ' ' -f 2 | xargs -I {} docker rmi $(DOCKER_IMAGE):{}

readme:
	@docker run -t --rm \
		-e DEBUG_LEVEL=DEBUG \
		-e DOCKER_USERNAME=${DOCKER_USERNAME} \
		-e DOCKER_PASSWORD=${DOCKER_PASSWORD} \
		-e DOCKER_IMAGE=${DOCKER_IMAGE} \
		-v $(DIR):/data \
		dsuite/hub-updater
