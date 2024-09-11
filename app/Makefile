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
build:
	@echo "Building Go binary..."
	go build -o bin/$(APP_NAME) main.go

.PHONY: docker-build
docker-build:
	@echo "Building Docker image..."
	docker build -t $(ECR_REPO):$(IMAGE_TAG) .

.PHONY: ecr-login
ecr-login:
	@echo "Logging in to AWS ECR..."
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(DOCKER_REPO)

.PHONY: docker-push
docker-push: docker-build ecr-login
	@echo "Pushing Docker image to ECR..."
	docker push $(ECR_REPO):$(IMAGE_TAG)

.PHONY: clean
clean:
	@echo "Cleaning up..."
	rm -f $(APP_NAME)
