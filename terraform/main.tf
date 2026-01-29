terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "6.28.0" }
  }

  # Optionally uncomment this for remote state storage. Required for updating infrastructure from multiple machines.
  # backend "s3" {
  #   bucket  = "demo-api-terraform-state-bucket"
  #   key     = "demo-api-terraform.tfstate"
  #   region  = "eu-central-1"
  #   profile = "default"
  # }
}

provider "aws" {
  profile = var.profile
  region  = var.region
}
