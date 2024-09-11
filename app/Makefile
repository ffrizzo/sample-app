SHELL := /bin/bash

.PHONY: help
help:  ## Show help messages for make targets
	@echo "Tasks"
	@grep -E '^[a-zA-Z_-]+:.*? ## .*$$' Makefile \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

APP_NAME := sample-app
BASE_VERSION := 1.0
GITHUB_RUN_NUMBER ?= 0.dev
VERSION = $(BASE_VERSION).$(GITHUB_RUN_NUMBER)
DOCKER_REPO := ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com
ECR_REPO := $(DOCKER_REPO)/$(APP_NAME)
IMAGE_TAG := $(VERSION)

ifeq ($(AWS_ACCOUNT_ID),)
$(error AWS_ACCOUNT_ID environment variable is not set. Please set it using `export AWS_ACCOUNT_ID=<your-aws-account-id>`)
endif

.PHONY: build
build: ## Build go project to run from local environment
	@echo "Building Go binary..."
	go build -o bin/$(APP_NAME) main.go

.PHONY: docker-build
docker-build: ## Build a docker image
	@echo "Building Docker image..."
	docker build -t $(ECR_REPO):$(IMAGE_TAG) .

.PHONY: docker-run
docker-run: docker-build ## Run project with docker image
	@echo "Building Docker image..."
	docker run -it --rm -p 8080:8080 $(ECR_REPO):$(IMAGE_TAG)

.PHONY: docker-push
docker-push: docker-build ecr-login ## Publish the docker image into the ECR
	@echo "Pushing Docker image to ECR..."
	docker push $(ECR_REPO):$(IMAGE_TAG)

.PHONY: ecr-login
ecr-login: ## Helper to login on ECR
		@echo "Logging in to AWS ECR..."
		aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(DOCKER_REPO)

.PHONY: clean
clean:
	@echo "Cleaning up..."
	rm -f $(APP_NAME)
