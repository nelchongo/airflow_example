provider "aws" {
    profile = "default"
    region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.8.0"
    }
  }

  backend "s3" {
    bucket = "fs-data-terraform-dev"
    key    = "data/data-state"
    region = "us-east-1"
  }

  required_version = ">= 1.0.3"
}
