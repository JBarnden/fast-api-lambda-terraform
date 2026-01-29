# FastAPI Lambda Terraform

A terraform project to quickly spin up a containerised, serverless FastAPI project on AWS with support for multiple environments.

# Pre-requisites

You'll need Docker set up to build your API image.

## Quick start

1. Create a tfvars file for each environment you want to deploy to (e.g. `development.tfvars`, see `development.example.tfvars` for example)
1. To use an AWS profile other than `default`, set the `profile` variable in your environment `tfvars` file, or in a `secrets.auto.tfvars` file to set it across all environments (see `secrets.example.tfvars`)
1. From the `terraform` directory, run `terraform init`
1. Run `terraform plan -var-file="development.tfvars"` and/or `terraform apply -var-file="development.tfvars"` as needed

If you need to force a re-build of the image:

`terraform taint null_resource.image`

If you want to tear down the environment:

`terraform destroy -var-file="development.tfvars"`

## Local development (Docker + hot reload)

The Lambda entrypoint is `handler = Mangum(app)` in `code/main.py`, but for local
development you can run the FastAPI app directly with `uvicorn` and hot reload.

From the repo root:

1. `cp .env.development.example code/.env.development`
1. `docker compose up --build`
1. Visit `http://localhost:8000/hello`

This uses `docker-compose.yml` + `code/Dockerfile.dev` and mounts your `code/`
directory into the container, so any changes to `main.py` or other modules are
picked up automatically. Environment variables are loaded from
`code/.env.development`.

## Running tests

Install dependencies from the `code` directory and run pytest from the repo root:

1. `pip install -r code/requirements.txt -r code/requirements-dev.txt`
1. `pytest -q code/tests`

Or run tests from docker container with dependencies:

1. `docker compose up -d tests`
1. `docker compose exec tests bash`
1. `pytest -q code/tests`

## Terraform - What it do?

In short, the terraform code will:

- Package the FastAPI code in the `code` directory into an image whenever a file change is detected
- Deploy the image to an ECR repository
- Create or update a Lambda function (when needed) that uses the latest image pushed to that ECR repository

There's also a configurable lifecycle policy that can be set for each environment to delete older images from ECR

## FastAPI - What it do?

- Very basic API with a `/hello` endpoint that:
  - Returns the demo environment variable in a payload
  - Logs the demo secret key (from the secrets file to prove it's working)

Useful references:

- https://spacelift.io/blog/terraform-tfvars

Inspired by: https://medium.com/@vladkens/effortless-aws-lambda-deployment-with-terraform-fastapi-docker-2023-87793b2a7866
