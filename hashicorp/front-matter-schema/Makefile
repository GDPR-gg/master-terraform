# References
# Pull the project name from the parent folder name
PROJECT := $(notdir $(CURDIR))
GIT_COMMIT=$$(git rev-parse --short HEAD)
SHELL = sh -xv

.PHONY: build 
build:
	# Build Docker image
	@SSH_AUTH_SOCK=$(SSH_AUTH_SOCK) DOCKER_BUILDKIT=1 docker build \
		--rm \
		--force-rm \
		--ssh=default \
		--squash \
		--iidfile  /tmp/$(PROJECT) \
		--tag \
		$(PROJECT):latest \
        .

.PHONY: sync 
sync: build 
	# Sync the package-lock.json if it was created inside docker
	@docker cp $(shell docker create $(PROJECT)):/package-lock.json package-lock.json

.DEFAULT_GOAL := sync 

