SHELL := /bin/bash

# The directory of this file
DIR := $(shell echo $(shell cd "$(shell  dirname "${BASH_SOURCE[0]}" )" && pwd ))

VERSION ?= latest
IMAGE_NAME ?= ps1337/kali-docker
CONTAINER_NAME ?= kali

# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


# DOCKER TASKS
# Build the container
build: ## Build the container
	sudo docker build --rm -t $(IMAGE_NAME) .

build-nc: ## Build the container without caching
	sudo docker build --rm --no-cache -t $(IMAGE_NAME) .

run: ## Run container
	xhost +local:root && \
	sudo docker run \
	-it \
	--net=host \
	--name $(CONTAINER_NAME) \
	-e DISPLAY=$$DISPLAY \
	-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
	-v ~/.vimrc:/root/.vimrc:ro \
	-v ~/.vim:/root/.vim:ro \
	-v ~/.zshrc:/root/.zshrc:ro \
	-v ~/.oh-my-zsh:/root/.oh-my-zsh:ro \
	-v ~/.exports:/root/.exports:ro \
	-v ~/.aliases:/root/.aliases:ro \
	-v ~/.inputrc:/root/.inputrc:ro \
	-v ~/.bindings:/root/.bindings:ro \
	-v $(DIR)/tmp/zsh_history:/root/.zsh_history \
	-v $(DIR)/sharedFolder:/var/sharedFolder \
	-v $(DIR)/data:/tmp/postgresData \
	$(IMAGE_NAME):$(VERSION)

stop: ## Stop a running container
	sudo docker stop $(CONTAINER_NAME)

remove: ## Remove a (running) container
	sudo docker rm -f $(CONTAINER_NAME)

remove-image-force: ## Remove the latest image (forced)
	sudo docker rmi -f $(IMAGE_NAME):$(VERSION)

restart: ## Restart the container
	make remove; make run
