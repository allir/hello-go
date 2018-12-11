NS ?= allir
IMAGE_NAME ?= hello-go
IMAGE_TAG ?= latest

.PHONY: help
help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

.PHONY: build push release default
build: Dockerfile ## Build docker image
	docker build . -t $(NS)/$(IMAGE_NAME):$(IMAGE_TAG)

build-nc: Dockerfile ## Build docker image (No cache)
	docker build . --no-cache -t $(NS)/$(IMAGE_NAME):$(IMAGE_TAG)

push: ## Push docker image to repository
	docker push $(NS)/$(IMAGE_NAME):$(IMAGE_TAG)

release: build push ## Build and Push image to repository

