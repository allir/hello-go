BIN_DIR := $(shell go env GOPATH)/bin
GOLANGCI-LINT := $(BIN_DIR)/golangci-lint
SHORT_SHA := $(shell git rev-parse --short HEAD)
VERSION := $(shell (git describe --tags 2>/dev/null || echo v0.0.0) | cut -c2-)

PKGS := $(shell go list ./... | grep -v /vendor)

.PHONY: clean
clean:
	rm -rf ./release

.PHONY: test
test: lint
	go test $(PKGS)

.PHONY: lint
lint: $(GOLANGCI-LINT)
	$(GOLANGCI-LINT) run --enable gofmt --skip-dirs-use-default ./... 

BINARY := hello-go
PLATFORMS := windows linux darwin
OS = $(word 1, $@)

.PHONY: $(PLATFORMS)
$(PLATFORMS):
	GOOS=$(OS) GOARCH=amd64 go build -ldflags "-s -w" -o release/$(BINARY)-v$(VERSION)-$(OS)-amd64 

.PHONY: release
release: $(PLATFORMS)

DOCKER_REPO := allir/hello-go
.PHONY: docker-build docker-release
docker-build:
	docker build . -t $(DOCKER_REPO)
	docker tag $(DOCKER_REPO) $(DOCKER_REPO):$(VERSION)
	docker tag $(DOCKER_REPO) $(DOCKER_REPO):$(SHORT_SHA)
docker-release: docker-build
	docker push $(DOCKER_REPO)
	docker push $(DOCKER_REPO):$(VERSION)
	docker push $(DOCKER_REPO):$(SHORT_SHA)

$(GOLANGCI-LINT):
	curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(BIN_DIR) v1.21.0
