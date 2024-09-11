# Sample Go Application

This repository contains a basic Go application that can be built into a Docker image and deployed to AWS Elastic Container Registry (ECR).

## Application Overview
This is a simple Go web server built with github.com/julienschmidt/httprouter for routing. The server responds with a welcome message at the root endpoint and is designed to demonstrate building, containerizing, and deploying a Go application using Docker and AWS ECR.

### API Endpoints

Below are the available endpoints for this application:

#### 1. **`[GET] /hello_world`**

- **Description**: This endpoint returns a simple JSON response
- **Response**:
  ```json
  {
    "message": "Hello World!"
  }

#### 2. **`[GET] /current_time`**

- **Description**: This endpoint returns a simple JSON response
- **Params**:
  - name: Value will return on JSON response
- **Response**:
  ```json
  {
    "message": "Hello {name}",
    "timestamp": 1700000000
  }

#### 3. **`[GET] /healthcheck`**
- **Description**: This endpoint returns HTTP Status OK if service is health


## Build and Publish

This section explains how to build the Go application, build the Docker image, push it to Amazon Elastic Container Registry (ECR), and run the Docker container locally.

### Prerequisites

Before you begin, ensure you have the following installed:

- Go (version 1.23+)
- Docker
- AWS CLI (with configured credentials)

You also need to export your AWS account ID as an environment variable:

```bash
export AWS_ACCOUNT_ID=<your-aws-account-id>
```

Getting help from make file
```bash
make help
```
