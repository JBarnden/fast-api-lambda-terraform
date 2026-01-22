# FastAPI Lambda Terraform

A terraform project for to quickly spin up a containerised, serverless FastAPI project on AWS with support for multiple environments.

# Pre-requisites

You'll need Docker set up to build your API image.

## Quickstart

1. Create a tfvars file for each environment you want to deploy to hold non-sensitive values (e.g. `development.tfvars`)
1. Create a `secrets.auto.tfvars` file with `cp secret.example.tfvars secret.auto.tfvars`
1. To use an AWS profile other than `default`, set the `profile` variable in `development.tfvars`
1. From the `terraform` directory, run `terraform init`
1. Run `terraform plan -var-file="development.tfvars"` and/or `terraform apply -var-file="development.tfvars"` as needed

If you need to force a re-build of the image:

`terraform taint null_resource.image`

## Terraform - What it do?

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