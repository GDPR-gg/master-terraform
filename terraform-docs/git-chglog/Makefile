.PHONY: bootstrap
bootstrap: clean deps

.PHONY: deps
deps: vendor

.PHONY: vendor
vendor:
	go mod vendor

.PHONY: clean
clean:
	# rm -rf ./vendor/
	rm -rf ./dist/
	rm -rf ./git-chglog
	rm -rf $(GOPATH)/bin/git-chglog
	rm -rf cover.out

.PHONY: bulid
build:
	CGO_ENABLED=0 go build -o git-chglog

.PHONY: test
test:
	go test -v `go list ./... | grep -v /vendor/`

.PHONY: coverage
coverage:
	goverage -coverprofile=cover.out `go list ./... | grep -v /vendor/`
	go tool cover -func=cover.out
	@rm -rf cover.out

.PHONY: install
install:
	go install ./cmd/git-chglog

.PHONY: changelog
changelog:
	@git-chglog --next-tag $(tag) $(tag)
