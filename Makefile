BIN_DIR := $(GOPATH)/bin
SHORT_SHA := $(shell git rev-parse --short HEAD)
VERSION := $(shell (git describe --tags 2>/dev/null || echo v0.0.0) | cut -c2-)

PKGS := $(shell go list ./... | grep -v /vendor)

.PHONY: clean
clean:
	rm -rf ./release

.PHONY: test
test: lint
	go test $(PKGS)

BIN_DIR := $(GOPATH)/bin
GOMETALINTER := $(BIN_DIR)/gometalinter

$(GOMETALINTER):
	go get -u github.com/alecthomas/gometalinter
	gometalinter --install &> /dev/null

.PHONY: lint
lint: $(GOLANGCI-LINT)
	golangci-lint run --enable gofmt $(PKGS)

BINARY := hello-go
PLATFORMS := windows linux darwin
os = $(word 1, $@)

.PHONY: $(PLATFORMS)
$(PLATFORMS):
	mkdir -p release
	GOOS=$(os) GOARCH=amd64 go build -o release/$(BINARY)-v$(VERSION)-$(os)-amd64 ./cmd/hello-go

.PHONY: release
release: windows linux darwin

GOLANGCI-LINT := $(BIN_DIR)/golangci-lint
$(GOLANGCI-LINT):
	curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.21.0
