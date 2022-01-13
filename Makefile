
GOPATH := $(shell go env GOPATH)
BIN_DIR := $(GOPATH)/bin

BINARY := hello-go
BUILD_ARGS ?= -ldflags "-s -w"

SHORT_SHA := $(shell git rev-parse --short HEAD)
VERSION ?= $(shell (git describe --tags 2>/dev/null || echo v0.0.0) | cut -c2-)

PKGS := $(shell go list ./... | grep -v /vendor)

.PHONY: help
help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

.DEFAULT_GOAL := help

.PHONY: clean
clean: ## Clean workspace
	@echo Workspace cleaned...
	@rm -f ./${BINARY}
	@rm -rf ./release

.PHONY: test
test: lint ## Run tests
	go test $(PKGS)

.PHONY: lint # Run lint
lint: $(GOLANGCI-LINT)
	$(GOLANGCI-LINT) run --enable gofmt --skip-dirs-use-default ./... 

PLATFORMS := windows linux darwin
OS = $(word 1, $@)

.PHONY: $(PLATFORMS)
$(PLATFORMS):
	GOOS=$(OS) GOARCH=amd64 go build ${BUILD_ARGS} -o release/$(BINARY)-v$(VERSION)-$(OS)-amd64 

.PHONY: build
build: ${BINARY} ## Build binary

${BINARY}:
	go build ${BUILD_ARGS} -o ${BINARY}

.PHONY: release 
release: $(PLATFORMS) ## Build release binaries

DOCKER_REPO := allir/hello-go
.PHONY: docker-build docker-release
docker-build: ## Build docker image
	docker build . -t $(DOCKER_REPO)
	docker tag $(DOCKER_REPO) $(DOCKER_REPO):$(VERSION)
	docker tag $(DOCKER_REPO) $(DOCKER_REPO):$(SHORT_SHA)
docker-release: docker-build ## Push docker image to repository
	docker push $(DOCKER_REPO)
	docker push $(DOCKER_REPO):$(VERSION)
	docker push $(DOCKER_REPO):$(SHORT_SHA)

GOLANGCI-LINT := $(BIN_DIR)/golangci-lint
$(GOLANGCI-LINT):
	go install github.com/golangci/golangci-lint/cmd/golangci-lint
